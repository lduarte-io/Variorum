# VX-677 run kickoff — editor, panes & the AI door (pre-launch)

**STATUS: READY FOR KICKOFF — her rulings landed at the 2026-10-28 sitting (the morning bundle pass + the #248/#249 walk). Every member's ruling, trace or fix shape is ON ITS TICKET; this file is the brief and the roster.**

**Kickoff (paste-ready):** `/run-phase vx-664 vx-656 vx-668 vx-572 vx-674 vx-675 vx-676 vx-663 vx-662 vx-680 vx-681` — ADOPT the standing run ticket **VX-677** (minted at the sitting; all eleven members are already its sub-issues — verify the listing at kickoff, never mint a second run ticket; the branch and PR take VX-677's number).

## The members (eleven; one line each — the ticket is the brief)

- **VX-664 (High)** — a live pane whose take changes from OUTSIDE writes the old words back on the next keystroke. **HER RULING on the ticket:** the ring ends ONLY when an outside write lands on the live pane's OWN take; every outside-change road (Compare/Canvas/Write's panel restores, sync apply, MCP edit_take/restore_commit, another window) gets the VX-222/VX-440 ring-ending shape; P-3's buffer authority is never bent; NO clean-buffer adoption. The bound-take half is VX-248 (landed at VX-601). EDITOR SEAM.
- **VX-656 (High)** — Write's full-document editor carries VX-421's undo class (window-manager registration, teardown clears nothing). Fix shape on the ticket: the pane road (owned manager via `undoManager(for:)`) or a teardown history end; `PaneUndoLifecycleTests` is the pin shape. EDITOR SEAM; TEXTKIT2_NOTES binding.
- **VX-668 (Medium)** — the Block History read-in-full sheet's Restore applies but never LANDS (caret at block's end, no wash) when opened from the inspector; the trace plan and the pull-the-parcel fix shape are on the ticket. TRACE FIRST with the app.
- **VX-572 (High, Pre-launch)** — the ⌘/ shortcuts pane overhaul: search, grouped collapsible headers (collapsed by default), corrected spacing, the description column in the voice's face (Study's on descriptions; the chord column may stay mono), sane wrapping (no mid-name breaks in the chord column). Her verbatim wants are on the ticket.
- **VX-674 (Medium)** — Block History: an unnamed commit's resting row carries a short muted preview of its words (P-440-9's flagged gap, ruled).
- **VX-675 (Medium)** — `show_in_app` accepts a saved-version id → opens the version full-size under its identity band; the deliberate refusal retires. MCPSpec carries the contract line at the merge.
- **VX-676 (Medium)** — `show_in_app` lands as an OFFER. ALL FOUR SEMANTICS SETTLED on the ticket: default = ask, at the toast's full prominence; toast → an automatic quiet line at the bottom bar's trailing end until taken/replaced/disconnect (one ✕ on each — the toast's ✕ sends to the line, the line's ✕ kills the ask; no zzz); the dial is GLOBAL in Settings ▸ MCP (move at once · ask · never); the wire answers at once, fire-and-forget, the activity log records ask and take. MCPSpec + the guide's chapter carry the words; **her standing allowance: the instructions bound may rise to 3,250 if needed.**
- **VX-663 (Medium)** — Read ▸ Pages arrivals open at page one; seed AFTER adopt, with an arrival pin (mechanism on the ticket).
- **VX-662 (Low)** — the stale Index carry anchor (written on her selection, never cleared); fix shapes on the ticket.
- **VX-680 (Medium)** — Index → Outline lands block-precise (the carried block's row scrolled into view), P-B4-1's ruled option.
- **VX-681 (Medium)** — leaving Read ▸ Scroll carries from the story on screen (VX-645's follow-highlight knows it), B4-P4 ruled in.

The last four are one navigation-carry family (with VX-630, shipped) — batch them together.

## Cast, seams, process

- **Opus implements, Fable cold-reviews** (editor seam present → Fable ladder for the whole diff). Preflight per CLAUDE.md IN FULL, plus: `notes/TEXTKIT2_NOTES.md` (VX-664/656 touch `EditorTextView`/`PaneSurface`), `notes/MCPSpec.md` (VX-675/676 are door changes — the wire's shapes, the grant rule, the instructions bound), and SurfaceContracts' sections for the note, the Bookcase and books, and Doors (the MCP door).
- **NO Sync/ and no custody.** VX-678 (the Trash/purge run) holds the one Sync/-touching slot in parallel. If any member's fix drifts toward `Sources/VariorumCore/Sync/`, STOP and report to the author — do not touch it from this run.
- **The stage:** the coordinator is **oct27coordinator** (holding since the overnight wave) — announce yourself and take every stage window through it. Worktree per the parallel rule (`~/dev/variorum-vx677` or similar; `~/dev/variorum` stays main).
- **Merges:** serialize with VX-678 — first-ready merges first, the other rebases and re-runs overlap suites. The shared ledgers only at the merge moment, on latest main.
- **NO release at close.** ONE release after BOTH runs merge; its notes state the release fact "local-only migration v1_34" (VX-648's), and it is her field-guide re-seed window. If VX-633's Machiavelli seed lands in time it joins the same release (her word).
- **QUESTIONS numbering:** #249 is the last used; take the next free at closeout and coordinate with VX-678's closeout through the coordinator (the #247→#248 renumber precedent).
- Canon deltas at closeout in the two-file shape: MCPSpec (VX-675/676's contract lines), SurfaceContracts (the note's Block History lines, the books' carry lines), AppSpec §12 only where a cross-cutting rule changes; the dated narrative to `notes/AppSpecRecord.md`; `Tools/canon-size` line in the handoff.

## Her acceptance notes

- VX-664/656: the walk proves the ring-end on at least the MCP edit road and one restore road live; VX-656's fix shows a clean ⌘Z after a mode switch on film.
- VX-572 is taste-adjacent: shots of the pane at rest (both voices) in the handoff for her verdict; her screenshots from the sitting are the before.
- VX-676: the walk films the ask toast → quiet line → take, and a dismissed ask; the wire transcript shows the offered answer.
