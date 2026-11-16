# Umbrella 2 — VM-55 · Umbrella: Wings underneath

Wave 1 · labels Umbrella, Mobile, App shell · High · Todo · project "Mobile — the catch-up & launch".
Order inside it: VM-56 (the phone's current wing) first; VM-61 (the message line) before VM-63 (the wing brains hoist).

| Ticket | Title | Kind · Evidence · Area · Priority | Rows | Mockup |
|---|---|---|---|---|
| VM-56 | The phone remembers which wing it is in, and every root says which | Feature · — · App shell · High | W-015, W-019 | `design/mockups/home-wings-capture.html` (the wing band) |
| VM-57 | Every list shows only the current wing | Feature · — · Library & sidebar · High | W-033 | `design/mockups/library-and-search.html` · `home-wings-capture.html` |
| VM-58 | New notes, books and tags are born in the current wing | Feature · — · Library & sidebar · High | W-034 | `design/mockups/home-wings-capture.html` |
| VM-59 | Tag suggestions and book pickers stay inside the note's own wing | Bug · Confirmed · Library & sidebar · High | W-035 | — |
| VM-60 | The tag manager shows and makes tags in the current wing | Feature · — · Settings & onboarding · High | W-229 | — |
| VM-61 | One message line: Undo when something leaves the page, and refusals | Feature · — · App shell · High | W-012 | `design/mockups/note-write.html` (D) · `home-wings-capture.html` |
| VM-62 | Refusals in plain words, never raw error text | Bug · Confirmed · App shell · High | W-013 | — |
| VM-63 | Move the Mac's wing brains to shared code | Debt · Confirmed · App shell · High | W-016 | — |

Blocked-by: VM-57, VM-58, VM-60 ← VM-56 · VM-63 ← VM-61. VM-62 "lands best after" VM-61 (related, not blocked). VM-59 waits on nothing.
All 9 rows placed: 012 013 015 016 019 033 034 035 229.

## Existing tickets re-homed or related

- **VM-6** (umbrella, the 13i family faces) related to VM-56 and VM-57, with a line saying they carry 4a's current wing (W-015) and scoped listings (W-033).
- **VM-7** (umbrella, editor and capture) related to VM-61, with a line saying VM-61 carries the one message line (W-012).
- **VM-12** (the leftover review backlog) related to VM-62, with a line saying VM-62 carries the raw-error refusals (W-013).

No open VM ticket was this same work, so nothing was re-homed.

## Closing candidates

- None from this umbrella alone (VM-6, VM-7 and VM-12 carry rows in other umbrellas too).

## Notes

- W-019's "Now in …" receipt is not drawn: her "only removals and refusals" ruling and the mockup's build notes ("No line is shown for it") rule it out. VM-56 draws the wing's name as the title only.
- SW-6 (`receipt_style` on the phone) is not among the recorded rulings; the sitting's recommendation was to honour it. VM-61 builds the ruled line shape and marks the setting's reach PROVISIONAL if it matters.
- Scoping without the wave-2 switcher would show one wing only (umbrella description's agent notes).
