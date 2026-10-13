# VX-214 orchestrator — compaction handoff (2026-10-13, ~03:15)

*Written at her instruction before a mid-run compaction. The post-compaction session is the SAME orchestrator (settingspaneupdater) continuing the SAME run. The repo is the memory: read this file, then the run record IN FULL, before any act.*

## Role, as amended tonight

Orchestrator of **VX-214 — Run: settings panes & launch UI polish** under `/architect-phase` discipline, with HER OVERNIGHT MANDATE (recorded verbatim in the run record's sitting section): continue through the night — remaining batches → the FABLE cold ladder over the whole diff → merge (merge `main` INTO the branch first if others landed) → the `/Applications` refresh behind the A1 rail at a zero-instance window. She is asleep; PROVISIONAL-and-continue everything except author-only hard stops; bundle anything needing her for morning.

## The documents (read order)

1. **`notes/plans/fixes/vx-214-settings-launch-polish.md`** — THE run record, in full: ledger (rows 1–12), every sitting ruling VERBATIM (General pane, the caption principle R-VX214-2, the step-follows ruling R-VX214-1 + pre-ruled contingency, the VX-225 widen, the overnight mandate), the batch briefs, ENVIRONMENT TRAPS, both batch RECORDs, contact-point agreements (vx-184, vx-201).
2. `notes/plans/vx-214-settings-pane-process.md` — the pane-pass process note for HER ticket VX-234 (do not build those panes; they're hers now).
3. Memory: `vx-214-run-state.md` (the compact map).

## State at cutover — VERIFY AGAINST GIT, never trust this section

- Branch `vx-214-settings-polish`, worktree `~/dev/variorum-vx-214`, the Pro. All work pushed continuously.
- **Batch 2 (VX-218 · VX-220 · VX-224 · VX-225) — CLOSED by its implementer at 03:15, VERIFIED by the orchestrator (head `d04388ba`, tree clean; commits/files/ledger spot-checked).** All four fixed with pins/oracles + walks (212/22 green at 03:00; the 2 in-window issues dispositioned). **OWED TO THE FINAL WHOLE-SUITE PASS:** AppMenuServicesTests 2/2 (post-Divider-removal re-green, stage-needing) + NoteBoxTests/NoteBoxMountTests/StarredScrollTests (named by file not struct, so they never ran; SidebarLayout constants only ADDED to). **OWED AT THE MERGE:** log VX-220's PROVISIONAL (Services suppressed in ALL configurations; a Debug-only keep = one `#if !DEBUG`) in `notes/QUESTIONS.md` on latest main. **HER POST-MERGE CHECKLIST (accumulate into the morning bundle):** the literal "Signed out" face on her real store (VX-218) + the real Castle lock closing Settings (VX-224) + the title bleed gone on her Release build (VX-225). **Rebase-awareness hunks for vx-201/vx-184** (promised; send at our merge): VariorumApp.swift Settings{} body (8f29619a) · AppSettingsView.swift constants + two .frame lines (f16220c3, clear of :175-192) · ProtectionStatusRow.swift one padding line (8d75819a) · EditorCommands.swift the empty services group (16022e76) + the removed MCP Divider (d2cad2f2).
- **General pane (VX-215's half): DONE, STANDS** (her word). Final Confirmations caption = her refusal sentence ALONE. Refusals stay toast-always — her explicit morning-adjacent ruling: "I think that refusals being more obvious is a good thing still." NO change, NO ticket.
- **Not yet done:** batch 3 (VX-217 gathering foot · VX-221 tag-delete button · VX-223 small dropdown text) — brief NOT yet written; batch 4 (VX-227 step-follows, ruled R-VX214-1 + contingency pre-ruled) — brief NOT yet written. Write each brief INTO the run record before spawning (one implementer at a time, fresh per batch).
- Then: the **fable-reviewer ladder** (DECIDED: fable — the one-live-ring content; REVIEW_PROMPT.md verbatim, zero framing, findings repo-first, the cross-model flow since Opus implemented) → implementer sanity pass → merge → refresh.

## Operational protocol (proven tonight — keep it)

- **Stage:** EVERY xcodebuild test / GUI walk needs a window from **oct12coordinator** (cross-session): implementer sends ME "READY: …", I relay, coordinator GOes with the exact claim line, I relay GO, implementer releases promptly, sends "RESULT: …", I relay. xcodebuild BUILD and headless swift test are stage-free. Check `df -h` before big builds (the volume hit 99% earlier; I freed ~22 GiB; ~44 GiB free at last check).
- **Shared record file:** implementers own ONLY their `### BATCH N RECORD` section; I warn before my edits ("hold until file's yours"), pathspec-limited adds ONLY (an unstaged sweep caused the bada900b collision — benign, recorded).
- **Peers:** vx-184 (MCP pane is THEIRS + VX-199; merging before us — rebase onto them; the divider deletion is OURS by their written OK), vx-201 (holds the custody slot; their VX-206 will add a Protection-landing adopter to AppSettingsView mirroring MCP's `adoptMCPRequest` pattern — they send us the hunks; their copy register rules bind our Protection/Data Safety wording — moot now, those panes are VX-234's), VX-179 (comment area — stay out).
- **Linear:** board flips auto-revert to In Progress when commit attachments land — re-set state after. Members: VX-222 Done · VX-218/220/224/225 flip Done when batch 2's hand-back verifies · VX-219 out (Needs Lillian) · VX-234 = her pane pass (Needs Lillian) · VX-216 re-own at closeout (detach from parent, she slept before it ran) · VX-215 closes with the run (its continuation is VX-234).
- **Merge protocol (hers, verbatim):** "if someone merges in before you, merge their work into yours and then merge." Closeouts serialize; PR titled `VX-214: …`, MERGE COMMIT, never squash. At the merge moment, on latest main: retire the in-flight row, board snapshot untouched (bout-start only). After merge: delete branch (GitHub + local), remove worktree, delete run/walk evidence + this run's DerivedData folders, close/re-own every ticket, memory update, the MOBILE PARITY line ("nothing mobile-visible" — all Mac chrome), AppSpec delta: NONE (zero canon-level behavior changed EXCEPT… check: the Settings copy changes are faces, no §12 contract line edits needed; VX-227's step-follows extends the liveness contract — if the ladder agrees it's contract-worthy, note for HER morning rather than editing canon autonomously).
- **The refresh (the culmination):** zero-instance window via coordinator (pgrep by PATH; HER real-store app must not be running — it's night, but VERIFY) → A1 safety copy into the container's `Backups/safety-copies/` → `xcodebuild -scheme Variorum -configuration Release build` → copy to `/Applications` → `codesign --verify`. Refresh ONLY after the merge.

## Morning bundle (hers, accumulating — deliver when she wakes)

- VX-234 (pane pass) + VX-219 (colour picker) + VX-216 (book/gathering menus) await her.
- The British-English question is parked on VX-234 (survey: consistently British, ~11 colour sites).
- VX-225's mechanism remains UNEXPLAINED (fixed by her ruled widen; Debug title's ~4-pt residual is a named Debug-only artifact).
- If the ladder finds anything needing adjudication beyond the spec, hold it for her.

## Machinery lessons (don't relearn)

Linear MCP needed her re-auth once (vx CLI is read-only; GraphQL via Keychain key also works). The choose-button bug's full mechanism/pin/fix story is in the VX-222 RECORD — don't re-derive. VX-225's oracle red-proof is ARITHMETIC (dispositioned in the record). SettingsShapeTests pins General's EMPTY blurb deliberately. The app-menu Services suppression + the widen are in; captures live in `notes/plans/vx-214-screens/` (gitignored).
