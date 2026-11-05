# VX-828 — editor & shell QoL: the author's handoff

*(Run record: `notes/plans/fixes/vx-828-editor-shell-qol.md` — read its FOR A LATER READER first.
Ladder findings: `notes/plans/fixes/vx-828-ladder-round1.md`. DRAFT until the merge; the PR
number, merge SHA and canon-size line land at closeout.)*

## YOUR MORNING CHECKLIST

1. **Ratify (or redirect) the run's PROVISIONALs — all built, none blocking:**
   - **P-828-1** ⌘digit past the wings speaks a refusal ("There's no wing 9 — ⌘1–⌘3 go to your 3
     wings, Home first."), and the CURRENT wing's number (or the switcher's pick of the current
     row) lands in its Bookcase — the identity switch counts as deliberate.
   - **P-828-2** the marquee is a TICKER (rest 2.5 s, 25 pt/s, 24-pt gap, seamless wrap); still
     under Reduce Motion; not drawn under 24 pt of room.
   - **P-828-3/-4** (VX-840) Trash-held wearers keep a tag off the unused list; the bulk delete is
     ONE ⌥⌘Z entry "Delete Unused Tags" (redo = the single delete's own semantics).
   - **P-828-6 (+ the ladder's addendum)** the carried word rides down with the caret at the new
     block's start; a caret beside punctuation inside a word's run (e.g. `beta|,`) rides the WHOLE
     run down — named for your eye, within the ruling's letter.
   - **P-828-7/-8/-9** the sweep's edge clause (any edge row to a live block), empty = zero-length,
     block tags aren't history.
   - **P-828-10 + wordings pass:** the sweep door's confirm/receipt words (in the record, built
     verbatim); ONE OVER-CLAIM the ladder caught — the nothing-left refusal says "not in the Trash
     any more" where some blocks may merely no longer qualify. One sentence to tune if you care.
   - **P-828-11..14** (VX-823) the place anchors on the ON-SCREEN rows (not the opened row — under
     the edited sort the opened row moves to the top, which was your complaint); the return mark
     wears the subject face with no panel; every leave records; Cards keep the place only.
2. **Two interpretive calls of mine to check (both flagged when made):**
   - **Q-B1:** your VX-824 "while no note holds the keys / the VX-560 text-input family" is built
     as a WRITING-SURFACE gate: editors, panes and comment fields swallow ⌘digit; text FIELDS and
     the quick-entry/capture boxes pass it through. The literal reading would have made the chord
     dead on the Bookcase (VX-332's resting caret) and killed chained presses.
   - **Q-B2 + the one regression:** ALL switcher doors land in the Bookcase (your "consistent"),
     including the masthead's cycling word — so stepping wings by repeated clicks now needs a
     re-aim per step. If that stepping pattern matters to you, flipping that one door back is a
     cheap redirect (VX-834 stays the eventual preference).
3. **Tickets this run filed:** **VX-855** (High — SQLCipher codec SIGSEGV under
     `PurgeJanitor.collectRoots` at test teardown; handed to vx-809's neighborhood) · **VX-856**
     (Low — the book Index/Outline position courtesy, assessed not cheap at batch C).
4. **VM candidates, yours to nod at (not minted):** a phone Trash sweep door (VX-800's twin); a
   phone tag-manager sweep (VX-840's twin). Nothing in this run is mobile-visible.
5. **The release:** if this run merges LAST of the wave, the release-ready window runs per the
   coordinator's plan — artifacts only, NOTHING published until your word.

## What shipped (one line per member)

- **VX-806** Return mid-word divides at the word's start — the whole word rides down; her
  screenshot's one-word-quote case pushes down instead of refusing.
- **VX-655** the list-exit Return's retraction lands inside the structural flight — no frame-blank.
- **VX-800** the Trash's "Delete N empty blocks…" door — R-828-1's predicate, intents only,
  confirm ∩ still-qualifying, no ⌥⌘Z.
- **VX-636** the Trash's messages speak in their own band below the rows.
- **VX-823** the Library remembers where you were (place + mark), per pane, in memory.
- **VX-824** ⌘1–⌘9 go to wings outside a note; refusal past the count.
- **VX-833** every deliberate wing switch lands in that wing's Bookcase; the follow never does;
  the label right-aligned at the column.
- **VX-844** the long wing name ticks like a car radio, clipped, never crossing the line.
- **VX-798** ⌘; / ⌘: one-shot spelling + the Edit ▸ Spelling and Grammar menu home.
- **VX-838** Settings ▸ Tags says "Tags — in ‹wing›" and follows the wing live.
- **VX-840** Settings ▸ Tags' "Delete N unused tags…" sweep, consuming vx-809's
  `tagSubtreeIsWorn` (vendored byte-identical until the merge reconciles).

## Evidence shape (detail in the record)

Every member: pins red-on-old by behavioral revert (or mutation probes where new), suites green
in stage windows, live walks in both voices. The ladder's round 1: **0 BLOCKER · 0 MAJOR**, one
MINOR (a test-doc honesty fix on the batch C road pin, in flight), four NITs dispositioned. One
walk catch mattered: VX-823's first build landed at the top on the REAL return road while every
mounted pin passed — fixed, re-walked green; the road pin is recorded HOLLOW as red-on-old (the
cross-window live pair is the evidence) with a ladder flag for a harder pin.

## Deferred to the merge-gate window (each covered by a green pin today)

Batch C's seven walk legs (Cards, search sheet, day filter, resets, deleted-row, sidebar leave,
two-pane) · B's remaining door witnesses, label seam/floor/fullscreen, the snippet-editor chord,
⌘/ rows · E's Settings legs (words-guard withheld ×3, fail-closed — fixture ready: tag
"husk-tag", unused, in Home; the third wing "the long-winded third wing of walking" kept) · the
amended road pin's red-show under R-C4 · the A+D phone suites (TYPEs verified: MobileStructural,
MobileTakeReorder, MobileTakeToBlock, MobileTrash, MobileNoteTray, MobileVersions).

## Lessons this run banked

The FILE-vs-TYPE `-only-testing` trap bit three times (TutorialWalkTests, MobileTakeStructure,
ShellLanding/Windows/PaneSplit/Tour) — always grep the TYPE. One order-isolation flake
(BrowserNavKeys' webview pin red under a new neighbor order, green alone). words-guard withholds
with Settings open (AXError -25200, batch A's class) — fail closed, captures deleted unread.
Shared memory repo: pathspec adds only (the coordinator's add-all swept a checkpoint). The
session's usage limit expired a stage claim mid-window (07:11–10:31) — the coordinator held, no
state lost; the resume sheet carried everything.
