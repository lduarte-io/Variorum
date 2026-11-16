# Umbrella 22 — VM-216 · Umbrella: Launch readiness

Wave 6 · labels Umbrella, Mobile, Tests & tooling · Low · Todo · project "Mobile — the catch-up & launch".
Medium inside it: VM-220 (crash reports) and VM-222 (the privacy manifest), per the brief. Order: VM-13 (her device window) → VM-217 (the selection bug, once the experiment names its cause); VM-222 and VM-223 share the project file: serialize.

| Ticket | Title | Kind · Evidence · Area · Priority | Rows | Mockup |
|---|---|---|---|---|
| VM-218 | Every screen works with VoiceOver and at the largest text size | Improvement · Confirmed · App shell · Low | W-014 | — (`export-and-share.html` frames 26–30 for large text) |
| VM-219 | A touch of haptic feedback on the main acts | Improvement · Confirmed · App shell · Low | W-011 | — |
| VM-220 | Crash reports, opt-in and off until you turn them on | Feature · — · Settings & onboarding · Medium | W-216 | `design/mockups/lock-and-protection.html` S1–S2; `first-run-and-joining.html` E2 |
| VM-221 | What's new, as a row in Settings ▸ Help | Feature · — · Settings & onboarding · Low | W-226 | `lock-and-protection.html` S1; `first-run-and-joining.html` E2 |
| VM-222 | The privacy manifest and the export-compliance key the App Store asks for | Debt · Suspected · Tests & tooling · Medium | W-255 | — |
| VM-223 | A build number that rises with each upload, a road to testers, and a Debug build that installs beside the real app | Feature · — · Tests & tooling · Low | W-256, W-257 | — |
| VM-13 (re-homed) | The device queue: the remaining walks on her phone, in one window | Task · — · Tests & tooling · Low | W-260, W-214 | `lock-and-protection.html` S2 (Debug rows gone from Release) |
| VM-217 | Holding to select text no longer scrolls the page up | Bug · Confirmed · Editor · Low | W-173 | — |
| VM-224 | The leftovers: stale comments and docs, the parity ledger tidied, and one untraced savepoint path | Debt · Confirmed · Tests & tooling · Low | W-261, W-262, W-263 | — |

Blocked-by: VM-217 ← VM-13.
Outside the umbrella (named in text, related): VM-48 (text sizes, umbrella 1), VM-53 (the Settings list), VM-201 (the sync line's out-of-date door, umbrella 19), VM-203 (the Mac's door, which waits on VM-223), VM-65 (the performance leg VM-13 no longer carries), VM-9.
All 13 rows placed: 011 014 173 214 216 226 255 256 257 260 261 262 263.

## Existing tickets re-homed or related

- **VM-13** re-homed: parent VM-216, Needs Lillian → Todo (it waits on her window, not on a decision — said in its agent notes), Medium → Low (the umbrella's); retitled; labels kept as Task · Tests & tooling · Mobile (a Task is her hands-on work, CLAUDE.md's labeling rule); a pointer section appended. It now also carries W-214 (the edit-trace experiment retires at its close, as its own rider already said). No parent, no assignee when checked.
- **VM-9** (umbrella-shaped) related to VM-218, VM-220, VM-221, VM-222 and VM-223, with a "wave 6" line naming which carries each part; App Store presence (the iOS name reservation) is her own act and has no catch-up ticket.

## Closing candidates

- **VM-9** — every build part is now carried (VM-48, VM-218, VM-220, VM-221, VM-222, VM-223); only the App Store name reservation, her own act, is left in it.

## Notes

- VM-219 (haptics): which acts, and how much, isn't ruled; the ticket asks the run to propose the set at kickoff.
- VM-222: the export-compliance answer (whether the app's encryption is exempt) is hers to confirm; said in its agent notes.
- W-256 and W-257 merged (both are the phone target's build settings, one file); VM-223 is labelled Feature for W-256, with W-257's "inferred" said in its text.
