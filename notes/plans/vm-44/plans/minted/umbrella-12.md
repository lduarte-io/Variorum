# Umbrella 12 — VM-137 · Umbrella: Writing

Wave 3 · labels Umbrella, Mobile, Editor · Medium · Todo · project "Mobile — the catch-up & launch".
The editor seam: the umbrella's description says its diff needs the Fable cold review (CLAUDE.md, Phase execution) and that the run reads `notes/TEXTKIT2_NOTES.md` at preflight.
Order inside it: VM-138 (the capsule, which carries the in-block newline key) → VM-140 (Return) → VM-141 (the switch); VM-139 follows VM-138; VM-142, VM-143, VM-144, VM-145 and VM-146 do not wait.

| Ticket | Title | Kind · Evidence · Area · Priority | Rows | Mockup |
|---|---|---|---|---|
| VM-138 | One capsule above the keyboard, and ⋯ opens a quick row: Undo, Redo, Comment, Commit | Improvement · Confirmed · Editor · High | W-134 + the quick row (her idea; no row) | `design/mockups/note-write.html` C1–C3 · `design/sketches/LK-4-LK-3-keyboard-bar.html` |
| VM-139 | The formatting buttons big enough to press, with a setting for all eleven in one row | Improvement · Confirmed · Editor · High | W-135 | `design/mockups/note-write.html` C6–C8 · `design/sketches/LK-4-LK-3-keyboard-bar.html` |
| VM-140 | Return makes a new block, as on the Mac | Feature · — · Editor · Medium | W-125 | `design/mockups/note-write.html` NT-1 |
| VM-141 | A note's own "Newlines make blocks" switch | Feature · — · Editor · Medium | W-126 | `design/mockups/note-write.html` NT-1 (the switch's place) |
| VM-142 | "Make every newline a block" and "Split this block at its newlines" | Feature · — · Editor · Medium | W-127 | — (places named in `note-write.html` NT-1, E) |
| VM-143 | Backspace joins two blocks and removes an empty one, as on the Mac | Feature · — · Editor · Medium | W-128 | `design/mockups/note-write.html` NT-2 |
| VM-144 | A cross-block edit says where every block went, and a new block says nothing | Improvement · Confirmed · Editor · Medium | W-129, W-140 | `design/mockups/note-write.html` D2–D5 and the block-act table |
| VM-145 | Paste as plain text, and quotes, dashes and spelling as on the Mac | Improvement · Confirmed · Editor · Medium | W-130, W-131 | — |
| VM-146 | Merge with next beside Merge with previous, and every block act reachable with the keyboard down | Feature · — · Editor · Medium | W-138, W-136 | `design/mockups/note-write.html` C3, F1, D4 |

Blocked-by: VM-139 ← VM-138 · VM-140 ← VM-138 · VM-141 ← VM-140. Related: VM-146 ↔ VM-138.
Outside the umbrella (named in text): VM-2 (the keystroke fence, umbrella 3 — Return and backspace land after it), VM-61 (W-012, the message line), VM-16 (the undo door's words), VM-13 (the device gesture-matrix walk), W-180 (umbrella 17, naming a commit), W-212 and W-150 (umbrella 13, Settings ▸ Writing and the note's menu), W-139, W-141, W-144 (umbrella 13), W-148, W-168 (the comments sheet's rework).
All 12 rows placed: 125 126 127 128 129 130 131 134 135 136 138 140, plus the capsule's quick row (VM-138).

## Existing tickets re-homed or related

- No open VM ticket was this same work, so nothing was re-homed.
- **VM-7** (umbrella, editor and capture faces) related to VM-140, VM-143, VM-144 and VM-145, with a "catch-up (wave 3)" line saying which carries the Return chain (W-125), the seam carves (W-128), the cross-block receipt (W-129) and the paste-plain door (W-130).
- **VM-1** (the hand-ins bundle) related to VM-143 and VM-145, with a line saying they carry the seam carves (W-128) and the plain-paste door (W-130).
- **VM-4** related to VM-146 (the merge vocabulary, NT-8), in the same line as VM-124.
- **VX-438** (one owner for smart quotes, Needs Lillian) related to VM-145 — relation only, no edit (VX).

## Closing candidates

- **VX-438** — the work list marks it absorbed by W-131 (VM-145), and NT-9 answers it ("quotes and spelling like the Mac"). It is a VX ticket about the Mac's panes too; close it only if the Mac half is settled — her triage.

## Notes

- Return is ruled (NT-1): no ticket offers "Return as content" as an option. VM-141's switch is the Mac's per-note chip, which already exists there.
- VM-138 carries one question for her, flagged by the designer: whether the quick row's Undo covers typing and structure (as drawn) or structure only (as today's note menu does). The ticket says to ask at the run's kickoff and otherwise follow CLAUDE.md's PROVISIONAL rule. Left in Todo, not Needs Lillian: the capsule and the rest of the row can be built either way.
- VM-139: where the strip choice is stored (device-local vs synced) is not ruled; the designer read it as device-local. Same handling.
- VM-140 owes a canon delta at its merge: AppSpec §7's "The phone's Return model is its own" changes in place to point at NT-1.
- VM-144 states the ruled answer for W-140: her "only removals and refusals" ruling supersedes NT-12's earlier default, so New block below says nothing and its Undo is the quick row's.
- VM-138 and VM-139 are High (W-134, W-135 are marked her priority HIGH); the rest are the umbrella's Medium.
