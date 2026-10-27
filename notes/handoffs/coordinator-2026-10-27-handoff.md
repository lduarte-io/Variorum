# Coordinator handoff — 2026-10-27 (pre-launch wave 1, overnight)

Session **oct26coordinator**, 01:56 → ~09:00 MDT, on the Pro. Your brief: wave 1 = VX-502 · VX-548 · VX-439 overnight; wave 2
(VX-601 · VX-562 · VX-559) as wave 1 merges; no `/Applications` refresh and no release without your word; one release when the
wave is done, with the notes drafted for you. Your overnight word: the Pro was mine through the morning.

## Your checklist

1. **VX-439's history call (M-3), which blocks the last wave-1 merge.** ~11 MB of walk screenshots and two Debug prefs
   exports rode two record commits into the branch's history (the tip is clean). (a) **"rewrite it"**, VX-439's
   recommendation: one force-with-lease of the unmerged branch at your word, then the merge. (b) **"merge as is"**: the
   11 MB enters main's history permanently. A pushed-history rewrite is yours alone. PR #194 is open and HELD, fully
   tested on top of VX-502 and VX-548 (the export seam re-proven on both merged trees). Say (a) or (b) to the vx-439
   session; its merge ask then comes to a coordinator.
2. **The release.** Nothing was released or refreshed. `/Applications` is still **0.10.2 (9462)**, untouched tonight; its
   A1 `variorum-a1-0.10.2-install-2026-10-25T095439Z` is the only real-store safety copy (nothing to prune). The wave's ONE
   release waits for VX-439's merge. **Notes drafted for you** (VX-502 + VX-548 written; VX-439's lines to add at its merge):
   the full text is under "Release notes draft" below. The version is yours to name. Release fact: VX-549 adds the
   **local-only migration v1_33** (MCP grants family). No server deploy, and the marker stays 14.
3. **Wave 2 hasn't started.** VX-601 · VX-562 · VX-559 are unstarted. I don't start sessions, and none was started overnight.
   VX-559's sitting waits for you anyway.
4. **Morning bundles:** QUESTIONS **#239(a)** (VX-502, built), **#243** (VX-548), and VX-439's bundle (in its handoff).
   Handoffs: `notes/handoffs/vx-502-handoff.md`, `notes/handoffs/vx-548-handoff.md`, and VX-439's on its branch
   (`notes/handoffs/vx-439-handoff.md` at PR #194). VX-439's also asks for: a ten-second VX-424 drag check, one
   Settings ▸ General visit, whether to order a Fable pass on its three editor-file chrome touches, VX-602's
   field-guide wording, and its PROVISIONALs. **Ledger catch:** VX-439's handoff names QUESTIONS #243 for its merge,
   but VX-548 already took #243. I told it to take the next free number at merge.
5. **New machinery, yours to keep or remove:** `~/.variorum/bin/type-dev-castle-secret` (VX-502's walk; R-510-8-shaped:
   types only `dev-castle.env` values, only into the Debug build by exact path, `--check` mode). You'd said "there are tools
   for putting it in", but none typed the dev values, so VX-502 built one as a provisional act. Its only live use was a
   non-mutating check door.
6. **Dev-store residue, yours to prune:**
   - the safety copy `…/Variorum-dev/Backups/safety-copies/variorum-vx502-walk-2026-10-27T102019Z` (9 files, cmp OK);
   - in the dev library's Trash: walk content from VX-548 and VX-439 (30-day);
   - an approved MCP client row "claude-code" with zero grants (no delete door short of Deny);
   - an empty "Walk Wing" (the switcher has no delete).
7. **Two older pins were EDITED rather than code changed** (each judged by its run's ladder; worth your eye):
   - VX-548 MID-1: VX-330's Book Panel pin collided with VX-354's ruled header icon;
   - VX-548 final: a batch-3 parity pin that predated your ratified gathering supersession (VX-273 flip class).
8. **Tickets born tonight** (triaged by their runs; see `notes/TICKETS.md`):
   - **VX-603**: Export Note… intermittently disabled in Write (open-intermittent);
   - **VX-604**: a lone-suite Mac run can false-green, "0 tests in 1 suite passed". Every session reported executed counts
     tonight because of it;
   - **VX-608**: `DestructiveUndoWarningTests.redoNeverAsks` red ON MAIN. Main's only code since VX-550's clean 10-26 suite
     was VX-502's export/Protection work (nothing near undo), so it's likely order/state-dependent;
   - VX-439's others: VX-614 (masthead pin flake), VX-615 (a gathering's menu says "Delete Book…"), VX-616 ("+ new
     chapter" on a gathering's foot), VX-617 (NoteCards' false flat-cost claim), VX-618 (autosave's full-record wakes);
   - VX-548's: VX-609–611 (walk findings) and VX-612/613 (MB-13);
   - VX-605–607 (from the wave's runs; see the board).
9. **The dev store's posture is recorded again.** `dev-castle.env`'s notes had gone stale since 10-18 (they named 86a82b4f).
   The live dev library has been **e11e5233** (key 77f4a14d), Standard, HELD since 10-20 (VX-309), signed out, under the same
   pair. VX-502 added the no-values posture note. The pair never changed tonight.

## Merges

| Effort | PR | Merge commit | Time (MDT) | Notes |
|---|---|---|---|---|
| VX-502 | #192 | `32fb88ec6` | ~04:58 | first merger on the export seam; ledgers `31d2b5750` before, banner `dd469951e` after; custody-adjacent slot freed |
| VX-548 | #193 | `d92c30d21` | ~07:18 | ledgers `6def23df0`; 74 code files, 5 overlapping VX-439 (merged cleanly into VX-439, re-tested there) |
| VX-439 | open, HELD | — | — | waits on your M-3 history word |

## Stage numbers and timeline (from `~/.variorum/stage.log`)

11 grants, **0 expiries, 0 steals, 0 forced releases**. ~3 h 55 m of stage use between 02:48 and 08:47. Every release was
verified by me (stage FREE, no instances on the strict forms, no booted sims, and after every dev-store walk the slot's
key/hold files and Previous Libraries checked).

| Claim | Window | What |
|---|---|---|
| vx548-b1-walk | 02:48–03:06 | 141 tests/12 suites + Settings ▸ MCP walk |
| vx-439-b1-suites | 03:15–03:28 | 821 tests/152 suites + VX-332 revert |
| vx-439-b1-walk | 03:30–03:37 | batch-1 walk (W-439-1 found → VX-603) |
| vx-439-b1-diag | 03:45–03:49 | W-439-1 diagnostic |
| vx-502-walk | 04:06–04:51 | 594 tests/109 suites → SEAM → Castle-restore walk, 13 legs green |
| vx548-mid | 04:54–05:28 | 336 tests/39 suites + walk (Opus walker) |
| vx-439-b2-suites | 05:30–06:08 | 3,057 tests/495 suites on the merged tree (export seam re-proof) |
| vx-439-b2-walk | 06:11–06:28 | batch-2 walk |
| vx548-final | 06:39–07:11 | 466 tests/59 suites + gathering-grant drill (Opus walker) |
| vx-439-l1-verify | 07:50–08:12 | 1,562 tests/267 suites on the tree with VX-548 merged in + reverts + slice |
| vx-439-r2-verify | 08:43–08:46 | 80 tests/10 suites (1 layout flake, green alone) |

## Calls I made

- **The custody-adjacent slot** went to VX-502 by explicit grant at 02:05, after confirming VX-548 and VX-439 declared no
  `Sync/` and no custody. Freed at VX-502's "nothing further owed".
- **The VX-502 walk's credential plan** (your no-lockout word). I found no helper that typed `dev-castle.env` and told VX-502
  to stop rather than improvise. Then:
  - I accepted its R-510-8-shaped helper as a provisional act, on conditions: `--check` before READY, no value anywhere,
    a no-values comment in the env file;
  - I accepted its JOIN road: the walk library joins the castle vxtest account, so every Castle leg ran under the account's
    own recorded secrets via `type-prod-test-secret`. The dev pair was typed only at the non-mutating check door. The
    account's passphrase was changed back, so its files stayed true with zero edits;
  - I required a cmp-verified safety copy of the slot before leg 1.
- **I corrected my own instruction.** I had told VX-502 the as-found library was 86a82b4f, from the env file's stale notes.
  VX-548's walk report and VX-309's record showed the slot was e11e5233 (held). I sent the correction before VX-502's walk
  plan was approved: leg 1 records the actuals, and the end state is THAT library returned, never 86a82b4f.
- **The hold banner:** every dev-store walk was briefed "never press Resume" (one press would have consumed the as-found
  hold that VX-502's walk depended on).
- **VX-548's dev-store set-aside** (VX-512's zero-state) was approved with whole-folder-rename conditions. It never ran: the
  slot already had no clients.
- **Ordering:** VX-548's READY for vx548-mid landed seconds after I GO'd VX-502's walk; it waited (merge-gating first). VX-502
  then released 105 minutes early.
- **VX-439's merges are merges, not rebases.** Your "rebases" would rewrite a pushed branch, so I directed a merge of main
  in. After VX-548 merged, I named the five overlapping files and required their suites in VX-439's next window on the
  merged tree.
- **VX-604:** from 04:00, executed counts were mandatory in every RESULT line, and 0 executed = no verdict.

## What went wrong, honestly

- **My stale-posture instruction** (above) could have sent VX-502's hand-return to the wrong library. It was caught before
  any dev-store act, but it came from trusting the env file's notes over the walk records. Lesson: read the latest walk
  record, not the env notes.
- **"Renew +20" in my GO lines was wrong in spirit.** `Tools/stage renew` RESETS the expiry to now+N, so a renew can SHORTEN a
  claim. VX-548's walker caught it; I corrected the wording from 07:50.
- **One session's self-reported times were wrong.** VX-439 reported its b2 walk as "~07:20, ~70 min, two renews" when the
  log says 06:11–06:28, one renew. I had it correct its record to the log.
- **Two Fable classifier stops**, each handled by her standing remedy (the leg handed to an Opus walker under the same claim):
  VX-548's synthetic-input leg, and the expected Castle-walk class (VX-502 ran its walk on Opus from the start).
- **An APFS-clone DerivedData's stale sweep deleted nine files** in VX-548's batch-3 products dir. Those products were
  retired as evidence and all final runs came from a clean build. Worth a ticket if it recurs.

## Process notes

- **The join road** (a walk library joins an existing vxtest account and adopts its pair) is the cleanest way to run Castle
  legs without ever crossing the dev pair. Recommend it as the default for future Castle walks.
- **Walk residue accumulates in the dev library's Trash.** It's harmless, but the as-found grows with every walk.
- **The stage-log Monitor** (re-armed every 30 min) gave me every claim, release and renew without polling. Worth adding to
  the skill.

## Release notes draft (for your approval; one line per bullet)

Draft for her approval. VX-439's lines assume its merge. The version is hers to name, after 0.10.2. When approved, it lands as
`App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-<version>.md`, one line per bullet (the VX-343 parser trap).

```markdown
## Export a note, find your way around faster, and share with AI more steadily

Export a single note to a file, make a note inside the book you're in with one shortcut, and the sidebar and its Open list behave the way you'd expect. Older exports import again, and sharing with an AI client got steadier.

- File ▸ Export Note… (⌥⌘S) saves the note you're in as a file, exactly what Copy full text gives you.
- Exporting your whole library now writes each note the same way, takes included, so every file imports back whole.
- A plain-text export from an earlier Variorum imports again. An export from a newer Variorum than this one still refuses, and says so.
- ⌥⌘N makes a new note inside the book you're in, including a gathering.
- The wing you're in is always named beside the New Note button.
- Untitled notes show their first words in the sidebar instead of "Untitled".
- Dragging a note in the Open list drops it where you aim, one slot up or down included.
- Right-click a note in the sidebar to rename, delete, close, move or copy it to another wing, or export it.
- A new setting in Settings ▸ General hides starred notes from the Open list.
- Outside the text, ⌘← and ⌘→ go back and forward. Inside the text they still go to the start and end of the line.
- Find and replace in Write shows where you are among the matches, like "2 of 15".
- In a fresh, empty note, Tab from the body to the title offers today's date.
- Coming back to the Bookcase always puts the cursor in quick entry.
- Hover over an icon to see its name.
- "Restore deleted chapter" moved away from the two buttons that make new things.
- The Help menu names the field guide and the tutorial plainly.
- Two standing grants for different wings now stand side by side in Settings ▸ MCP. Before, granting a second wing could quietly take away the first.
- Settings ▸ MCP has a "Share a place…" door, and a line that explains the pane before any client has connected.
- You can now share a gathering with an AI client. It sees what the gathering gathers and never a Private note, and a note it writes there lands outside any book with the gathering's tags.
- A gathering built from stars can't take new notes from an AI client, and the client is told so plainly.
- In the Takes card, a take an AI client labelled keeps its own words, and hovering shows the whole label.
- The Book Panel's header and its gatherings show what an AI client can reach, like everywhere else.
- When an AI client adds a note to a book, it hears back every tag the note now wears.
- Stopping the MCP server, quitting, or a dropped connection now ends cleanly every time, and a stale start can no longer stop a running server.
```

