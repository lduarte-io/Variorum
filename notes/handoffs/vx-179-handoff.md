# VX-179 — the comment area pristine pass — her morning handoff (2026-10-13, overnight close; updated with her answers the same morning)

## Your checklist — things only your hands can judge

1. **The new comments panel, both voices, light and dark.** The composer is now a framed writing
   box (card paper + hairline, accent hairline while the caret is in it, the key hints and Add
   inside — P-VX179-U3-1); the caret sits ON the placeholder line (your screenshot's misalignment
   is gone). ⏎ makes a new line, ⌘⏎ files, ⟲/⌘Z undoes per area. The taste numbers
   (`CommentsPanelMetrics`) are PROVISIONAL — nudge anything that reads wrong.
2. **The gutter cards.** Stacked entries with hairlines, the card grows to its block's height
   (96 pt cap retired), scroll INSIDE an overflowing card: mouse-wheel down scrolls the card, up at
   rest moves the page, at the card's end the page takes over; the scroller-lane is draggable
   (knob or faded lane alike) and never opens the panel; a press anywhere else on the card does.
   **Please try a TRACKPAD gesture over an overflowing card** — the one arm no synthetic walk can
   drive (the mechanism is identical by dispatch-stack evidence, but your fingers are the proof).
3. **The popover (Takes margin note).** Type a draft, press ⎋ — it clears and the popover stays;
   ⎋ again closes. Edit a comment in place and click away — the edit SAVES now (round 1's reviewer
   found the loss; it was pre-existing since 13u3). An unsubmitted DRAFT still dies on click-away —
   **ANSWERED: you ruled it should be kept as a draft → VX-257** (not built yet).
4. **True delete.** A deleted comment's fold now carries "Delete forever…" beside Restore,
   confirm-each-time; it leaves every device by the 13j purge road. Under a SEALED post the purge
   REFUSES — **ANSWERED: ratified ("a fair choice").**
5. **The "#2" badge** at narrow windows now shows its whole count (was "…").
6. **Edit the last comment of a tall list** (small window, the sheet): the "Unsaved · ⌘⏎ · Save ·
   Revert" line stays in view as the row grows.
7. **Not walked, needs your eyes when convenient:** IME composition in the composer (W-U3-8); the
   TakesBottomBar sheet host (W-U3-11); the quick pad door (W-U3-13); the inline-strip opt-in with
   stacked cards.
8. **VX-226 — ANSWERED:** the read page stays comment-free; the INDEX view (Read's edit arm) gaining
   comments is VX-226, re-scoped and in Backlog (a design + build on the editor seam).
9. **VX-193 — ANSWERED:** fixed before launch (Pre-launch label).

## Small mysteries explained
- **The What's New sheet you kept dismissing** was this branch sitting at 0.9.3 while main went
  0.9.4 — every Debug alternation flipped the shared record. The merge ended it.
- Your walk note "2026-10-12" kept its walk debris, plus two tombstoned test comments in its
  Deleted folds (walk evidence; delete forever at your leisure — they're good first victims).

## What closed tonight (the record is `notes/plans/fixes/vx-179-comment-polish.md`)
- All four units (U0 Sync/ line · U1 true delete · U2 gutter cards · U3 panel) + five fix legs.
- The ladder: round 1 0B/0M/2m/1n → fixes → **round 2 0B/0M/0m/2n — CLOSED**, sanity pass agreed.
- Six stage windows + two walks; every fixed row proven in the live app, the popover ⎋ ladder with
  a DEBUG trace read (`comment-keys`); two pre-existing undo bugs fixed on the way (⌘Z crash +
  filing-undone-words desync).
- Found-work tickets: VX-182, VX-183, VX-193 (HIGH), VX-194, VX-226, VX-229, VM-14.
- The /Applications refresh: DONE — folded into VX-214's closeout refresh (0.9.4 build 6843,
  2026-10-13 11:27, A1 verified in their record). VX-179 merged first (d6caafc1), so the new comment
  editor is in your installed app.

## If anything above misbehaves
Say the word and the record's traces will carry a fix session straight to the mechanism — nothing
in this run was fixed without one.
