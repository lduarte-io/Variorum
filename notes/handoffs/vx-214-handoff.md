# VX-214 — handoff (Run: settings panes & launch UI polish) — CLOSED 2026-10-13

**Merged:** PR #156, merge commit `8925f38b`. **Installed:** Variorum 0.9.4 build 6843 in `/Applications`, through the folded refresh that also carried VX-179 and VX-201. The A1 safety copy is at `Variorum/Backups/safety-copies/folded-refresh-vx179-vx201-vx214-20261013T172728Z/`. The record: `notes/plans/fixes/vx-214-settings-launch-polish.md`. Your answers: QUESTIONS #217 (fully answered).

## Your checklist (needs your hands, on the new build)

- [ ] **Signed out (VX-218):** on a signed-out real store, the bottom-left "Signed out" words sit on the sidebar's edge, in line with the rows above. Only a real store shows this face.
- [ ] **Lock closes Settings (VX-224):** on your Castle store, open Settings, then lock (⌃⌘L or idle). The Settings window should close, with no stub left behind.
- [ ] **Title bleed (VX-225):** is the "Variorum Settings" title still bleeding over the pane? The widen should hide it. If you still see it, note which Mac; the deep trace is VX-236.
- [ ] **First open (F6, your pre-cleared call):** the first open of build 6843 on your real store may remove a leftover silent key copy. Nothing to do; just knowing.
- [ ] **Field-guide re-seed:** not part of the refresh. That press is yours (VX-201's handoff).

## The tickets

**From your answers:**
- **VX-250** (pre-launch): your copy and rule calls, one small build.
  - The shorter mint receipt.
  - The shorter greyed-button hovers.
  - Gathering rules with NOT terms allowed for new notes.
  - "Opening your library…" in Settings mid-ceremony. This closes VX-240.
- **VX-247** (pre-launch): undo (⌥⌘Z) for deleting a tag.
- **VX-249**: collecting an existing note into a gathering sets the star the rule needs, ignoring the 15-star limit, and its confirmation names the star.
- **VX-251**: consider abolishing the 15-star limit. Your lean: cap how many the upper-left pane shows, not how many can be starred.
- **VX-248**: the root fix. A live editor loads the new take's words when its take switches, ending the "one take's words saved into another take" class. Editor-layer work for Fable.
- **VX-238**: restoring a deleted tag. On the eventual plan, but a design memo comes first (owned books, outflow tags, gathering rules, Arrivals, a same-named tag, sync).
- **VX-194**: disabled calm-style buttons look clickable. Fix it in the style, then fold the gathering button's one-off back in.

**Opened by the run:**
- **VX-236**: the Settings title bleed's deep trace (cause unknown).
- **VX-241**: adding to an archived gathering wrongly says "the gathering shows it now".
- **VX-242**: on the Lenses board, the editor can end up invisible after delete, archive or column removal. No text is lost; Compare is unchecked.
- **VX-244**: "Show take ▸" appears where it can't act.
- **VX-245**: eight labels missing a line limit, red on main. vx-184 is fixing the two MCP ones.

**Re-owned or yours:**
- **VX-216**: the book and gathering menus pass (standalone; carries "This book has no notes yet." on an empty gathering).
- **VX-234**: your Settings pane pass, Editor through Acknowledgments, including MCP (`notes/plans/vx-214-settings-pane-process.md`).
- **VX-219**: the colour picker.

## What shipped

- **VX-222:** the Takes choose button now switches takes correctly. This is your onboarding repro, and it could also save one take's words into another.
- **VX-218:** signed-out spacing.
- **VX-220:** the Services submenu removed.
- **VX-224:** Settings closes on lock.
- **VX-225:** the sidebar widened, hiding the title bleed.
- **The General pane** as you ruled it.
- **VX-217:** a "+ new note" button on gatherings, greyed with a reason where it can't act; it sets the star when the rule needs one.
- **VX-221:** a visible tag-delete button; both delete doors share one confirm.
- **VX-223:** readable dropdown text, and the take card's single chevron.
- **VX-227:** stepping takes with ⌃⌘←/→ while editing moves the live editor with the step.

The Fable review closed clean at round 2. The full Mac suite ran on the merged tree (4,532 tests), with every unexpected failure explained in the record.

## Your standing rules recorded tonight

- **R-VX214-2:** a settings caption earns its place only if it says what using the app can't teach.
- **Edits act only in the editor that shows as live** (your answer on the mid-step keys).
- **Refusals stay as toasts**; only confirmations are quiet.
- **Dev-store Castle credentials** live at `~/.variorum/dev-castle.env`. Walks use exactly those, and the values are never written anywhere.

## Housekeeping

The worktree, branch, every build folder (including the Release build installed from) and the walk captures and stage logs are deleted, per the closeout rule; the record keeps the counts and findings. One leftover in the dev store: a Pool note titled "VX-227 walk…", which the batch-4 implementer left behind. Trash it if it's in your way.
