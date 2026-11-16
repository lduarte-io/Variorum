# Umbrella 16 — VM-176 · Umbrella: Speed, second pass ⚑

Wave 4 (⚑, the wave's one sync-touching umbrella) · labels Umbrella, Mobile, Performance · Medium · Todo · project "Mobile — the catch-up & launch".
The umbrella is blocked by **VM-65** (wave 1's timing readout): it runs only after the readout has numbers from her phone, and those numbers decide the order of its members. Any `Sources/VariorumCore/Sync/` line needs the Fable cold review (said in the description), as does any editor-seam line.

| Ticket | Title | Kind · Evidence · Area · Priority | Rows | Mockup |
|---|---|---|---|---|
| VM-177 | Typing in a long note stops re-reading the whole note at every pause | Bug · Confirmed · Performance · Medium | W-244 | — (audit F §4, §7, §8 P1.5) |
| VM-178 | The open note isn't delivered again when the sync push lands, a few seconds after typing | Bug · Confirmed · Performance · High | W-246 | — (audit F 2E, §10) |
| VM-179 | The takes marks lay out only the fanned blocks on screen, not every one in the note | Bug · Confirmed · Performance · Medium | W-245 | — (audit F §4, §8 P1.6) |
| VM-180 | Notes open on other tabs stop costing full price, and switching back doesn't re-read a long note | Bug · Confirmed · Performance · Medium | W-248 | — (audit F §4, §8 P3) |
| VM-181 | Control Center and banners no longer redraw the whole app | Bug · Suspected · Performance · Medium | W-251 | — (audit F §6) |
| VM-182 | A clean sync round no longer scans the whole library for deleted rows | Bug · Confirmed · Performance · Medium | W-250 | — (audit F 3B, §8 P1.4) |
| VM-183 | A sync round after a book is deleted for good no longer takes minutes | Bug · Confirmed · Castle & sync · Medium | W-210 | — |
| VM-184 | A first catch-up no longer holds the library for minutes while it saves | Bug · Confirmed · Performance · Medium | W-253 | — |
| VM-185 | Measure the book Read hitch on a very long note, on an iPhone | Debt · Confirmed · Performance · Medium | W-252 | — |

Blocked-by: umbrella VM-176 ← VM-65 · VM-178 ← VM-177. Each member names VM-65 (W-238) in text as its before-and-after measure.
All 9 rows placed: 210 244 245 246 248 250 251 252 253.
`Sync/` members: VM-182, VM-183; likely VM-184 and possibly VM-178 (INFERRED). Editor-seam members: VM-177, VM-179, VM-180.
VM-178 is High (W-246 is "HIGH (lag)" in the work list); the rest take the umbrella's Medium.
Her report after the VM-46 install (a minute-long round with nothing to send) is cited in VM-182 and the umbrella's notes as evidence for W-250 and W-239 (VM-67).

## Existing tickets re-homed or related

- None re-homed.
- **VX-672** related from VM-183 (W-210 absorbs it) — relation only, no edit.
- **VX-497** related from VM-184 (W-253 absorbs it) — relation only, no edit.
- **VM-11** related from VM-185 (its M14 measure moved here; VM-11's appended section says so).
- **VM-17** related from VM-179 (same file), **VM-70** from VM-180 (lands first), **VM-67** from VM-182 (the other half of the minute-long round).

## Closing candidates

- **VX-672** — wholly carried by VM-183; close when VM-183 lands (her triage, VX).
- VX-497 is NOT a candidate: her word on it is "don't close it" (audit E); it stays open until VM-184 actually fixes it.
