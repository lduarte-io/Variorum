# VX-915 — the recents sweep: your morning handoff

**STATUS: DRAFT IN PROGRESS (the overnight run is still moving — gate36b, ladder round 2 and the closing walk fill the placeholders marked ⏳). Final at closeout.**

---

## What happened tonight, in plain words

You asked for the recents sweep to run overnight: fourteen small follow-ups from the November waves, built, reviewed, tested and merged — with the release BUILT and ready, but **nothing published**. That is what happened (⏳ merge pending). Everything that needed your judgment was held and bundled rather than decided; the list of those is below under "Decisions waiting on you."

Here is each item, in plain words:

1. **The badge switch split in two (VX-934).** One Settings switch used to control both the *book* marks (the "also in other books" mark, the "owned by" chip) and the *AI* marks (the shared-with-AI icon, the Private eye). Per your ruling they're now separate: "Show ownership badges" went back to **Settings ▸ Editor** and controls only the book marks; a new switch at the foot of **Settings ▸ MCP** ("Show the shared and Private marks" — wording is yours to bless) controls the AI pair. The AI pair is on by default, synced, and the shared icon became hideable for the first time.
2. **Callout blocks no longer squeeze their text (VX-782, a real bug).** On the Takes board, text inside a coloured callout frame sat 5 points to the right and wrapped 10 points narrower than plain text. Now the coloured frame bleeds outward instead, so callout text lines up exactly with every other block. Proven by a test that fails on the old code.
3. **Compare columns breathe (VX-848).** Comment cards used to claim 150 points of every Compare column. Now columns show the slim badge lane by default, and full cards appear only when a column is wide enough to keep Write's whole text measure beside them. The exact threshold is provisional — yours to soften.
4. **Compare can start a comment thread (VX-793).** You couldn't add the *first* comment to a block in Compare (the menu item was grey). Now "Comments…" and ⌘⇧' open the panel on the block you're in.
5. **History speaks "as kept" (VX-927).** The lineage pane's "against now" chip and "N changes since" line now say "against as kept" / "N changes to the take as kept" when the take you're reading lives on as lineage rather than as the current text.
6. **The Cancel-less dialog hunt came back clean (VX-869).** The suspected class (a dialog with a text field and three-plus buttons never drawing its Cancel) was swept across all 45 dialogs in the app: zero remain — the one known case was already fixed last run. A guard test now keeps the class empty forever.
7. **The quick-note pad can aim at another wing (VX-841).** A quiet "Home ▾" word in the pad's header (only visible when you have a second wing) redirects one capture: it lands in that wing with that wing's own #quicknote tag and no Quicknotes gathering grows there — bookless, unless a living book in that wing collects the tag, in which case it seats there and the receipt names the book (the review caught the receipt claiming "the Pool" in that case) — exactly the wrinkle you ruled. The fast path (summon · type · ⏎) is untouched. A latent bug was fixed along the way: Home captures could have started failing once any other wing held a quicknote tag.
8. **Double-⏎ no longer files twice (VX-928, a real bug).** Pressing ⏎ twice quickly in the quick-entry band minted the same note twice. One in-flight guard now covers ⏎, ⌘⏎ and the button together. Proven failing on the old code at the gate.
9. **Your two tour sentences landed verbatim (VX-843).** The end card's keep-going door now names all five stops (Settings included), and the Prince front note ends on your restart sentence. Checked carefully: nothing compares seeded text byte-for-byte, so existing stores keep their old wording safely — no duplicates, no overwrites.
10. **The guide can now help someone whose secrets leaked (VX-916).** The protection chapter's "Standard and Castle" lesson gained the compromise-recovery recipe — the three moves in order, what they protect, the honest limit, why a fresh account isn't needed — plus the "your passphrase hasn't been typed on this Mac yet" explanation. Every sentence was checked line-by-line against the Castle rules; two places where your draft's wording would have contradicted a rule are flagged for you.
11. **Two guide fixes (VX-929).** "Getting around" now teaches ⌘⏎ (file without opening), and lesson 8's owned-book-delete aside is honest that archived notes stay archived.
12. **The punctuation-search bug doesn't exist (VX-888, closed hollow).** The reported disagreement between the search band and the sheet doesn't reproduce on today's code — the reproduction test passes, and stays as a guard. Two *real* search bugs found while tracing it were ticketed instead (VX-954, VX-955).
13. **The release script checks its own pins now (VX-852).** release.sh gained two verify-pins hooks (before the build and after the archive). Never executed tonight — the wave's release run is their first real exercise, with your eyes on it.
14. **Your agent's ask: links can be removed over MCP (VX-943).** The wire got `unlink_versions`: a client can remove a version link using the id `link_versions` returns. A hidden or missing link answers identically (nothing leaks), a saved version's link refuses in words (removing it would need Promote, a bigger act), and one ⌥⌘Z puts the link back. **One correction you should know:** the "same permission level" framing came from your agent's note, not from you — the permission rung (write-new on both notes, as built) is an OPEN question in your bundle, with the house precedents quoted.

**The night's review story, in plain words.** A cold reviewer read the whole run's code and found nothing broken — zero blockers, zero majors, four minors, eight nits. The minors were fixed (one receipt now names the book a capture actually landed in rather than claiming "the Pool"; a misattribution of your agent's words as yours was corrected in the records). The full test gates then caught two things the reviewer and builders missed: a test-spec error (fixed by making the test stricter, not weaker), and one real find — **the unlink receipt's words were one character too long for the status bar's budget, so every real unlink would have said "made a change" instead of naming the notes**; it now mirrors the link receipt's shorter shape ("unlinked “A” and “B” as versions" — provisional words, your pass). A SECOND fresh reviewer then re-read all the fixes: zero blockers, zero majors again (two small notes, both handled or bundled), and the re-run gate came back entirely green — 31 tests, zero failures. The review ladder is closed.

**The walk, in plain words.** I drove the app myself at the end: the pad's wing pick works exactly as ruled in both voices (and the receipt honestly says "the Pool of “Walk Wing”"), double-Return files once, the dialogs' Cancel keys work, and your agent's unlink round ran LIVE over the wire — a client linked two notes, removed the link with the id it got back, your receipt named both notes, the Open door landed in Compare showing "there is no relationship here", and ⌥⌘Z put the link back. The door's key fence even refused my hand-made key first, which is exactly what it should do.

**The merge and the release, in plain words.** ⏳ The run merges through the coordinator after the closing walk (main's other merged work — vx-913 — was already folded in and re-checked). `/Applications` was NOT touched (your VX-931 rule: releases only). ⏳ If this run is the wave's last merger, release prep runs at the coordinator's GO: version 1.4 built and stopped at the release script's HANDOFF — **nothing uploaded, nothing published, no appcast** — so saying the word in the morning is all that remains.

---

## Your checklist (⏳ finalized at closeout)

- [ ] Read the QUESTIONS bundle (**#273** — the P-915 family) and rule the open choices (the biggest: the unlink rung P-915-B6-1; the ai_marks carry-over P-915-L1-1; the Compare card threshold P-915-B2-1).
- [ ] ⏳ Wording passes: the AI-marks switch's words (F-934-B) · the quicknote landing receipts · the unlink receipt family · N-927's "as kept" grammar · the lesson-3 clause · the recovery recipe's order note (F-10).
- [ ] ⏳ The real-store guide RE-SEED (grown again this run: "getting around", "owned, finished, sealed", "Standard and Castle", lesson 3's clause — yours, behind A1, via Help ▸ Restore Field Guide…).
- [ ] ⏳ Release 1.4 at your word (the build is ready at release.sh's HANDOFF stop; VX-852's new pin-check lines will appear in its transcript — their first exercise).
- [ ] ⏳ The filed-tickets pass (the checkbox list at the bottom).

## Decisions waiting on you (each explained where it's bundled)

The QUESTIONS bundle entry (**#273**) carries the P-915 family with one-line plain explanations per item: P-915-B2-1 (Compare's card threshold), P-915-B2-2 (the comments door's reach), P-915-B3-1 (the pad's wing word — seat, face, words), P-915-B4-1/-2 (where the recovery recipe sits; where its words live), P-915-B6-1 (the unlink rung — OPEN, the agent's ask not your words), P-915-B6-2/3/4 (the saved-version refusal words; already-gone; still_versions), P-915-L1-1 (what a stored ownership_badges="0" means now), N-915-B4-1 (the restart sentence promises slightly more than the mend does), N-927's words, F-934-A/B, F-10 (the recipe's step order — true as built; a stronger order exists), F-12 (the not-shared noun for an edge id), plus the receipt-words family from the ladder fixes.

## Evidence and state (⏳ final numbers at closeout)

- Branch `vx-915-recents-sweep`, worktree `~/dev/variorum-vx-915`; PR **#240**; merge commit ⏳ (the coordinator serializes it); **canon-size 140,013 of 150,000 (headroom 9,987 — no crossing)**.
- The run record (everything, verbatim): `notes/plans/fixes/vx-915-recents-sweep.md` — its FOR A LATER READER section is the settled summary.
- Gates: gate12 + gate12b (batches 1–2, green; one rig fixed owner-aware, never weakened), gate36 (73 types, 456 tests, zero skips; both red legs watched; two first-run reds traced and fixed), gate36b (31/4, all green), the whole-Mac + phone merge gate on the folded tree ⏳ (runs at the coordinator's GO).
- The ladder: round 1 (0 B / 0 M / 4 MINOR / 8 NIT) + fixes verified; round 2 (0 B / 0 M / 2 MINOR / 5 NIT) — CLOSED, no round 3 earned.
- The closing walk: ALL GREEN (W-841 whole in both voices · W-928 both arms · W-869's S1/S2 · VX-943's live wire round end-to-end; the record's THE CLOSING WALK RAN section).

## Filed tickets (⏳ re-stated as the session's last chat message, by priority)

- [ ] **VX-955** (Medium · Bug · Search) — a symbol word beside real words empties the whole search answer.
- [ ] **VX-945** (Low · Debt · Tests) — the unconditional-forget DEBUG-oracle sweep (gate12's rig class, other oracles).
- [ ] **VX-947** (Low) — the Prince front note deleted alone has no restore road (the mend never counts front matter).
- [ ] **VX-948** (Low · Wording) — two remaining guide over-says of the VX-929 class (lesson 5, ritual R4).
- [ ] **VX-949** (Low · Wording · Castle & sync) — the backup folders' RESTORE.md runbook still advises "Replace All Keys" where the guide's new recovery recipe advises Use Castle; align or record why they differ.
- [ ] **VX-950** (Low · Bug · Settings) — the guide says "Account…, at the bottom of the sidebar" but the sync row's offline state shows no Account… door.
- [ ] **VX-954** (Low · Bug · Search) — a punctuation word beside a tag answers less than the tag alone.
- [ ] **VX-957** (Low · Bug · App shell) — the pad's wing word is blank for an instant after a park restore (face late, outcome right).
- [ ] **VX-958** (Low · Bug · App shell) — Home capture receipts can still over-claim "the Pool" when a Home book seats the note (the fixed class's one remaining arm).
