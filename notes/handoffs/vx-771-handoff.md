# VX-771 — Run: MCP agent ergonomics — author handoff (2026-11-04, the overnight away run)

**TL;DR.** All 14 members landed (11 feedback items + 2 riders + 1 found-in-run); the ladder closed at round 1 with no BLOCKER and no MAJOR; the Mac close ran 287 tests in 42 of 42 suites green; the walk verified the door's stop road live (the lock road's live check is yours — one minute on your Air, item 3 below). NO release, as you ruled. The record: `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md` (FOR A LATER READER at its top).

## Your checklist (the morning bundle, your calls first)

1. **P-771-1's reach — F-1(c), your call.** An undated, untitled source's copy now takes the source's creation day as `entry_date` — the duplicate doors, the wire, and Copy to Wing (A-771-1). Still re-dating that class: promote (lens → note), diverge-for-reading, the ownership forks. Extend, or leave? (Saved versions deliberately stay date-cleared — V3's rule.)
2. **P-771-1's residual, your eye.** A TYPED-titled undated source's copy stays undated — its name is faithful, but under the Library's entry-date sort it sorts by its own birth day. The alternative (date every undated non-journal copy) invents a date for a titled note.
3. **Your one-minute Air check (VX-762's field half).** Your Air's library is in Castle — the real field case the dev store (Standard) couldn't replay. Next time it locks with a client connected: Settings ▸ MCP ▸ Activity should read "‹client› was disconnected when the library locked or closed", and the client's MCP log "Variorum's library locked or closed, so it closed this connection — reconnect with /mcp once it's open again." (once a build with this run is installed there). The stop road itself was verified live tonight end to end, and the lock road's words are pinned by three green Mac suites.
4. **VX-762's client-side words (P-771-3), your pass.** A dropped client now learns why on its MCP log (the lock/close, switch-off and quit twins, plus the generic fallback). **The quit's line is flagged:** the quit now tells the client "Variorum quit…" while Activity still logs nothing for a quit (P-VX394-5 stands — that rule was about your log). Options A (seamless shim reconnect) and D (fewer locks) remain yours, unbuilt.
5. **VX-775 (Needs Lillian).** An Activity-write failure after a landed act answers the client an error for a write that landed. The new words say "may not have landed" (honest); whether that answer stops being an error — or the act and its log become one transaction — is your call.
6. **VX-763's verdict.** Your duplicate grant rows were the 2026-10-18 sighting — VX-393's bug, fixed at 0.9.8 (third filing: VX-393 · VX-565 · VX-763). The re-trace found ONE new road to the same face (a book grant on a gathering you bound into a book, then ⌥⌘Z of the bind) and fixed its listing — that row now reads gone, Revoke only. No migration was needed.
7. **The docs' tail (O-3/O-4), your wording pass or a ticket.** The field guide's MCP chapter names neither `create_gathering`, the `remove_tag` report, nor the replace form (its cards were never exhaustive); `MCPSession.instructions` sits at 3,061 of 3,100 and was left untouched. And `remove_tag`'s description points board flows at `create_gathering`, which only a write-new-on-a-wing client lists — "ask the author for a gathering" is the alternative wording.
8. **Sightings, no action owed:** VX-685 (twice) and VX-722 (once) flaked under whole-module load exactly as filed — comments left on both tickets. Batch 4's own pins were de-flaked (O-7, a test-only wait alignment).

## Filed tickets, by priority

- **Medium:** VX-774 (null-only edit_take empties the take) — FIXED in-run, closes with the PR.
- **Low:** VX-775 (Needs Lillian, item 5) · VX-776 (the SDK-handler store-failure words need a harness seam) · VX-777 (a stale start's stop speaks the switch-off words — VX-613's class) · VX-778 (a client row's count includes gone places).

## What shipped (one line each; the record's FOR A LATER READER has the mechanisms)

duplicate_note keeps an undated source's day (P-771-1) and takes `brief` + `fan_sha256` (P-771-8) · `copy_note_to_wing` (your ⇧⌥⌘L on the wire) · edit_take's honest mismatch (P-771-9) + the `old_str`/`new_str` replace form (P-771-10) · no store failure reaches the wire raw (P-771-11; the 19-row sweep) · `remove_tag` names the living tag-rule books that still hold the note (P-771-12; the eviction dial DECLINED as you ruled) · `create_gathering` (P-771-2) · the door's close line told to the client (P-771-3/A-771-3) · every stop ends until-disconnect grants (VX-400) · the kind-reverted grant listing fix (VX-763) · VX-767/768 verified already shipped (VX-566/VX-567).

## Evidence & bookkeeping

- Ladder: `notes/plans/fixes/vx-771-ladder-round1.md` (round 1, dispositions, the line-by-line check).
- The Mac close, canonical: "✔ Test run with 287 tests in 42 suites passed after 84.999 seconds with 4 warnings." (42/42 executed; the warnings are the dependencies date warning). Core on the merged tree: 3,637/489 green. MCP module whole: the pre-existing timing family only, each green alone.
- The walk: found = ended posture (Standard, HELD, unlocked, MCP switch OFF); `vx771-walk` denied, binding released; dev-castle.env untouched; prefs clean (735 keys, zero added/removed).
- Canon: MCPSpec's ten contract lines + AppSpec §9's duplicate-day line, one pointer each; `Tools/canon-size`: 129,905 of 150,000 (headroom 20,095) — no crossing.
- PROVISIONALs: QUESTIONS #257 (P-771-1..12). Mobile parity: the duplicate-day rule rides the shared operation, so any phone duplicate door heals identically; everything else is the Mac-only door.
- NO release (your word). The PR merged at the coordinator-serialized moment; the branch and worktree are gone; main's board snapshot refreshed.
