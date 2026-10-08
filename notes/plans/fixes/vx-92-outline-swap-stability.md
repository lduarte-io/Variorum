# VX-92 — Run: book Outline swap & click stability

**Run ticket:** VX-92 (In Progress) · **members** VX-82 (live→read blank beat) · VX-91 (rapid-click jitter) · **branch** `vx-92-outline-swap-stability` · **worktree** `~/dev/variorum-vx-92` (the Pro) · **session** `vx-82andmore` · **record started** 2026-10-07.
**Shape:** a RUN under the architect skill's process rules, read as the VX-75 shape at her kickoff words ("I need you to be a fix session for vx-82 and a family of other related bugs… you'll need to coordinate with claude session oct7coordinator when you need to test") — Fable investigates and implements; cold review by a fresh `fable-reviewer` (editor seam ⇒ the Fable rider); same-model ladder, the orchestrator arbitrates against the spec. Pin-before-fix PER MEMBER, revert-verified. Stage access via session `oct7coordinator` (name · need · duration · urgency); headless `swift build`/`swift test` free.

## Her report (2026-10-07, verbatim-faithful — the kickoff message)

> "Vx-82 should be fixed. additionally, when you're in outline and you click around a lot on the different options in the sherlock holmes adventure outline with all of the text expanded, sometimes things will start to bug and in the worst case, there will be some screen jittering and the title that you clicked on will appear alone in the middle of the page, with no other text on the screen. I'm not sure exactly how to trigger it - I've seen it on my pro and my air, so I'm certain it's not a regression from the precursor to vx-82, but I can't reliably trigger it. I'd say to look for what might be causing it and see if there's any wins that can be made, but I am aware that it's hard to fix a bug you can't reliably trigger and I'm not interested in spaghetti code to try to whack a mole the issue. If a flaw / bug can't be clearly diagnosed and found and pinned with a test, I don't want to make a half baked change to try to fix an issue I can't even reliably reproduce, even if I've seen it a few times. The editor is pretty solid which is great news! and this happened when very rapidly clicking on different items on the outline - but now I can't make it happen again, which is actually a good sign."

Readings to verify, not build on: VX-91's symptom is **rapid** clicking across **expanded** stories in the Sherlock book's Outline; "screen jittering" then, worst case, **the clicked title alone mid-page with no other text** — i.e. every other row's text de-realized or collapsed while the clicked row's header survives. Seen on BOTH Macs, pre-dates VX-75's fix (her own judgment), NOT reliably reproducible. Her binding rule: **no fix without a clear diagnosis and a red-on-old pin; investigation findings land here either way.**

## The members

- **VX-82 — the live→read blank beat.** Mechanism ALREADY TRACED (VX-75's ladder R1-4, confirmed by the reviewer; her 2026-10-07 confirmation "that pause is noticable" in the VX-75 build): when a live note stops being live (unfocus, pane-defocus, focus elsewhere), `OutlinePostRow`'s read branch mounts a FRESH `ReadPostView` that fills asynchronously — a reserved-height blank beat until its projection lands. Fix shape: VX-75's forward fix mirrored — the outgoing surface holds until the incoming one shows. Pin: the inverse of `theFirstClickIntoEditingNeverShowsAnEmptyNote`.
- **VX-91 — rapid-click jitter / clicked-title-alone.** Investigation-first; the speculative-finding road applies (pin FIRST as the confirm — a stress probe driving rapid focus flips across expanded stories while sampling the `BookOutlineGeometry` oracles; RED confirms a mechanism class, GREEN after honest effort ⇒ record-only, the ticket keeps the findings).

## LIVE STATUS

- **DONE** — kickoff: VX-91 minted (her words faithful), run ticket VX-92 minted, members sub-issued, all In Progress; worktree seated from origin/main (base `21ec6912`), branch pushed; in-flight row + board snapshot on main (`6a207d77`).
- **DONE** — preflight: CLAUDE.md canon (auto), TEXTKIT2_NOTES.md (full), SessionResiliencyProtocol.md (full), workflow-transition record (full), master plan in-flight table (overlap: VX-83 names the `EditorViewModel` landing road — file-level watch only; no effort claims the book Outline), QUESTIONS.md targeted pass (#97 · #99 · #103 · #150 — the outline/landing family), the VX-75 fix record in full (the governing prior).
- **IN-PROGRESS** — static trace of the post-VX-75 swap seam (both directions) + the VX-91 candidate mechanisms.
- **NOT-STARTED** — VX-82 pin (red-on-old) → fix → revert check → regression suites.
- **NOT-STARTED** — VX-91 stress probe (the confirm) → diagnosis or record-only.
- **NOT-STARTED** — ladder (fresh `fable-reviewer`, whole run diff) → PR `VX-92: …` → members closed.

## Findings

*(to be filled as traced — repo-first, before any fix lands)*
