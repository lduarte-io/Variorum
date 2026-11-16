# Umbrella 4 — VM-78 · Umbrella: Fixes to what's there

Wave 1 · labels Umbrella, Mobile (no Area: the members span the whole app, CLAUDE.md's labeling rule) · High · Todo · project "Mobile — the catch-up & launch".
Order inside it: none; the members are independent. In the "should not wait" set: VM-43, VM-16, VM-81 (W-105), VM-3.

| Ticket | Title | Kind · Evidence · Area · Priority | Rows | Mockup |
|---|---|---|---|---|
| VM-43 (re-homed) | The phone's restore doors don't insure the replaced words — wire insuringBuffer (P-849-1's rider, her ruling) | Bug · Confirmed · Takes & Lenses · High | W-181 | — |
| VM-16 (re-homed) | The phone's undo door mis-speaks a quiet press, and its offered Redo/Undo can act on a DIFFERENT entry (VX-276's rule, phone side) | Bug · Confirmed · App shell · Urgent (kept) | W-145, W-146 | — |
| VM-81 | Finish asks before it dismisses a book's arrivals, and book doors show only where they work | Bug · Confirmed · Books · High | W-105, W-106, W-110, W-120 | `design/mockups/a-book.html` (the Finish confirm) |
| VM-3 (re-homed) | Phone tutorial still TEACHES the retired duplicate-divide default (row 48) | Bug · Confirmed · Settings & onboarding · High | W-218 | — |
| VM-83 | Books sort a–z or by last edited, say “gathering” not “smart”, and keep one star door | Bug · Confirmed · Books · High | W-068, W-071, W-073 | `design/mockups/a-book.html` (the book's menu; New book) |
| VM-21 (re-homed) | The phone's membership add lists archived gatherings and its collect receipt overclaims (VX-241's twin) | Bug · Confirmed · Books · High | W-092 | `design/mockups/a-book.html` (the membership sheet's notes) |
| VM-33 (re-homed) | The phone's Trash draws "empty" before the first value (the Mac's VX-670 empty-flash, mobile sibling) | Bug · Suspected · Library & sidebar · High | W-057 | — |
| VM-17 (re-homed) | Phone fan badges may pile at the first block on long fanned notes, like VX-230 on the Mac (probe first) | Bug · Suspected · Editor · High | W-147 | — |
| VM-24 (re-homed) | MobileMarkdownCaretTests: the rescue-point replace test is red on the iOS 26.2 simulator (pre-existing; cause untraced) | Bug · Confirmed · Tests & tooling · High | W-258, W-259 | — |
| VM-84 | The note's date chip updates when the date changes | Bug · Confirmed · Editor · High | W-161 | — |

Blocked-by: VM-81 ← VM-62 (umbrella 2's refusals, for the sealed book's Reopen sentence).
All 17 rows placed: 181 145 146 105 106 218 073 068 071 057 092 110 120 147 161 258 259.

## Existing tickets re-homed or related

- **VM-43** re-homed: parent, project, Medium → High; labels Improvement → Bug · Confirmed · Takes & Lenses · Mobile (the work list's kind).
- **VM-16** re-homed: parent, project (was "Mobile — editor & capture faces"), Backlog → Todo; `Pre-launch` removed; Urgent kept; now also carries W-146 (VM-20's wording). Related to VM-20.
- **VM-3** re-homed: parent, project, Backlog → Todo, Medium → High; labels already to the rule.
- **VM-21** re-homed: parent, project, Backlog → Todo, Low → High; labels already to the rule.
- **VM-33** re-homed: parent, project, Backlog → Todo, Low → High; `Mobile` and `Library & sidebar` added (Suspected kept: the audit inferred it from this ticket).
- **VM-17** re-homed: parent, project (was "Mobile — editor & capture faces"), Backlog → Todo, Medium → High; labels already to the rule.
- **VM-24** re-homed: parent, project, Backlog → Todo, Low → High; labels Editor · Suspected → Tests & tooling · Confirmed (a failing test); now also carries W-259 (VM-19). Related to VM-19.
- **VM-20** related to VM-16, with a line saying VM-16 carries it.
- **VM-19** related to VM-24, with a line saying VM-24 carries it.

## Closing candidates

- **VM-20** — folded into VM-16 (the undo warning's word, W-146).
- **VM-19** — folded into VM-24 (the stale first responder, W-259; VM-24's own text already suspects it as the cause).

## Notes

- VM-16 and VM-17 carry an assignee (Lillian) set before this minting; left as found, against the never-an-assignee rule — hers to clear.
- VM-81's "Open Arrivals first" button needs the Arrivals review, which arrives in wave 4 (W-101). The ticket builds the confirm and its count now and leaves the button to join when the review exists.
- VM-83 merges three Shelf-file rows (sort, the pin door, the gathering word), so it carries no Wording label.
