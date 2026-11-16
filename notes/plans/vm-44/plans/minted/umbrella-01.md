# Umbrella 1 — VM-47 · Umbrella: Sizes and look

Wave 1 · labels Umbrella, Mobile, App shell · High · Todo · project "Mobile — the catch-up & launch".
Order inside it: VM-48 (type) → VM-49 (spacing and targets) → VM-50 (controls) → the screen-level members.

| Ticket | Title | Kind · Evidence · Area · Priority | Rows | Mockup |
|---|---|---|---|---|
| VM-48 | Text at phone sizes that grows with the system text size | Improvement · Confirmed · App shell · High | W-001, W-004, W-024 | `design/sketches/sizing-sheet.html` |
| VM-49 | Room to tap: one spacing scale and 44 pt touch targets | Improvement · Confirmed · App shell · High | W-002 | `design/sketches/sizing-sheet.html` |
| VM-50 | One set of phone controls: buttons, fields, sheet headers and choices | Debt · Confirmed · App shell · High | W-003 | `design/sketches/sizing-sheet.html` |
| VM-51 | The phone wears the library's voice and palette | Improvement · Confirmed · App shell · High | W-005, W-006 | `design/sketches/sizing-sheet.html` |
| VM-52 | The bottom bar: three words on a chip with real tap areas, on every root and list | Improvement · Confirmed · App shell · High | W-007, W-009 | `design/mockups/home-wings-capture.html` (the bar) |
| VM-53 | Settings as one scrolling, grouped list, reachable from every screen | Improvement · Confirmed · Settings & onboarding · High | W-211, W-008, W-213 | `design/mockups/lock-and-protection.html` (S1–S3) · `home-wings-capture.html` (the ⋯ menu) |
| VM-27 (re-homed) | The phone's Settings sheet shows two "Protection…" rows stacked while sync reads locked / not-yet | Bug · Confirmed · Settings & onboarding · High | W-217 | `design/mockups/lock-and-protection.html` (S1–S3) |
| VM-54 | Borders keep their old colours after a light or dark switch | Bug · Suspected · Editor · High | W-172 | — |

Blocked-by: VM-49 ← VM-48 · VM-50 ← VM-48, VM-49 · VM-52 ← VM-48, VM-49, VM-50 · VM-53 ← VM-48, VM-50.
All 14 rows placed: 001 002 003 004 005 006 007 008 009 024 172 211 213 217.

## Existing tickets re-homed or related

- **VM-27** re-homed: parent VM-47, project set, Backlog → Todo, Medium → High; labels already to the rule; a pointer section appended. Related to VM-53 (same file).
- **VM-9** (umbrella, beta readiness) related to VM-48, with a line saying VM-48 carries its Dynamic Type part (W-001).
- **VM-7** (umbrella, editor and capture) related to VM-51, with a line saying VM-51 carries the palette (W-005).

## Closing candidates

- None from this umbrella alone. VM-9 and VM-7 become candidates once every one of their rows has a home (the work list splits them across several umbrellas).

## Notes

- W-009 (the empty system bar on pushed screens) is inferred from code; VM-52 says to look on a simulator first. VM-52 is labelled Confirmed for its W-007 half.
- LK-1: her word was "follow the library"; whether the phone keeps a voice row that writes the library's voice is left to the build (VM-51's agent notes).
