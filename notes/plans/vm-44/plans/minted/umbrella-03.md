# Umbrella 3 — VM-64 · Umbrella: Timing and the two lags

Wave 1 (⚑, the wave's one protection-or-sync umbrella) · labels Umbrella, Mobile, Performance · High · Todo · project "Mobile — the catch-up & launch".
Order inside it: VM-65 (the timing markers and readout) first; every other member is blocked by it.

| Ticket | Title | Kind · Evidence · Area · Priority | Rows | Mockup |
|---|---|---|---|---|
| VM-65 | Timing markers and a readout, run on her phone before and after each fix | Debt · Confirmed · Performance · High | W-254 (markers and readout), W-238 | — (audit F §9–§11) |
| VM-66 | The phone's speed tests run the paths she actually uses | Debt · Confirmed · Tests & tooling · High | W-254 (the test half) | — |
| VM-67 | Launch and unlock stop scanning every table | Bug · Confirmed · Performance · High | W-239 | — |
| VM-68 | The Library reads a page at a time and stops re-reading everything on every keystroke | Bug · Confirmed · Performance · High | W-037, W-240 | `design/mockups/library-and-search.html` (the listing) |
| VM-69 | Opening a note reads it once | Bug · Confirmed · Performance · High | W-243 | — |
| VM-70 | A note's editor is released when the note closes | Bug · Confirmed · Performance · High | W-247 | — |
| VM-71 | Leaving a note or the app saves once, without holding up the capture box | Bug · Confirmed · Performance · High | W-249 | — |
| VM-2 (re-homed) | Phone structural flight has NO keystroke fence — mid-flight keystroke duplicates text in the STORE (row 95) | Bug · Confirmed · Editor · High | W-124 | — |

Blocked-by: VM-66, VM-67, VM-68, VM-69, VM-70, VM-71 and VM-2 ← VM-65 (the orchestrator's instruction).
All 9 rows placed: 254 238 239 240 037 243 247 249 124. W-238 is folded into VM-65 at her ruling (the device session is the readout run on her phone); W-254 is split into the readout (VM-65) and the simulator tests (VM-66), two separable pieces.

## Existing tickets re-homed or related

- **VM-2** re-homed: parent VM-64, project set, Backlog → Todo; already High; labels already to the rule; blocked by VM-65; a pointer section appended.
- **VM-13** (the device queue) related to VM-65, with a line saying VM-65 carries its performance leg (W-238).
- **VM-1** (the hand-ins bundle) related to VM-70, with a line saying VM-70 carries its autosave-registry leak (W-247).
- **VX-68** (the typing-flicker watch) related to VM-65 — relation only, no edit (VX).
- **VX-618** (autosave's full-record updates wake every observation) related to VM-68 — relation only, no edit (VX).

## Closing candidates

- **VX-618** — the work list marks it absorbed by W-240 (VM-68). It is a Core-level ticket the Mac shares, so close it only if VM-68's fix covers the Mac's half; her triage.
- **VX-68** — handed to the device session (W-238), which is now VM-65's readout; close when the readout has watched for the flicker.

## Notes

- VM-2 (store corruption, in the "should not wait" set) is blocked by VM-65 per the instruction; it claims no speed, so the coordinator may want to lift that block.
- VM-67 may need an index (a schema change, its own commit, SyncSpec §12 decides lockstep).
