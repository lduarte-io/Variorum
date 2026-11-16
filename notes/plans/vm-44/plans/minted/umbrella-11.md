# Umbrella 11 — VM-130 · Umbrella: Search

Wave 3 · labels Umbrella, Mobile, Search · Medium · Todo · project "Mobile — the catch-up & launch".
Order inside it: VM-131 (the hoist) → VM-132 (search) → every other member.

| Ticket | Title | Kind · Evidence · Area · Priority | Rows | Mockup |
|---|---|---|---|---|
| VM-131 | Move the Mac's search model to shared code | Debt · Confirmed · Search · Medium | W-060 | — |
| VM-132 | Search the words inside your notes, with the matching passage under each note | Feature · — · Search · High | W-059 | `design/mockups/library-and-search.html` §4 |
| VM-133 | Search all wings with one switch | Feature · — · Search · Medium | — (her ruling LS-2; no row) | `design/mockups/library-and-search.html` §4 (the scope control) |
| VM-134 | Search archived notes and commits when asked, and search blocks on their own | Feature · — · Search · Medium | W-061 | `design/mockups/library-and-search.html` §4 (the two switches, the archive foot) |
| VM-135 | Narrow a search with #tag, and choose the order of results | Feature · — · Search · Medium | W-062, W-063 | `design/mockups/library-and-search.html` §4 (the filter chip); the order door is not drawn |
| VM-136 | A search result opens the note at the match, with the match selected | Feature · — · Search · Medium | W-064 | `design/mockups/library-and-search.html` (build notes, "Landing on a match") |

Blocked-by: VM-132 ← VM-131 · VM-133, VM-134, VM-135, VM-136 ← VM-132. Related: VM-133 ↔ VX-987 (the Mac's twin) · VM-136 ↔ VM-129 (the shared landing brain).
Outside the umbrella (named in text): VM-56 (W-015), VM-80 (W-020, follow a note to its wing), VM-52 (the bar under results), VM-93 (the room names), W-132 (umbrella 13, wave 4 — Find, which the landing arms).
All 6 rows placed: 059 060 061 062 063 064, plus the all-wings switch (VM-133).

## Existing tickets re-homed or related

- No open VM ticket was this same work, so nothing was re-homed.
- **VX-987** (the Mac's all-wings search) related to VM-133 — relation only, no edit (VX). Not re-homed, as instructed.

## Closing candidates

- None.

## Notes

- VM-132 is High (W-059 is marked her priority HIGH); VM-131, its prerequisite, carries the umbrella's Medium per the brief's rule.
- VM-133 carries a canon delta owed at its merge: AppSpec §7's "Wings isolate totally … search … within ONE wing" line and SurfaceContracts' search contract change in place to name the all-wings switch as an explicit crossing (LS-2, VX-987). Core `SearchScope.wingID` is non-optional today; the all-wings scope is a Core change shared with VX-987 (whichever lands first builds it).
- VM-133 names one open edge for her (with VX-987): tags are per wing, so `#tag` narrowing under all wings needs a rule.
- VM-134 asks whether the Mac's mode facets (gathering, living, owned, finished, sealed) ride in v1; the mockup draws only the archived and commits switches.
- VM-136: arming Find with the matched word waits on W-132 (umbrella 13, wave 4); the landing and selection land here.
