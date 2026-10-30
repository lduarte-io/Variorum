#!/bin/bash
# notes-guard.sh — VX-708: ONE definition of the process-text shape that may never ship in release
# notes. The notes file is PUBLIC COPY — the in-app What's New sheet and the appcast's update alert
# render it verbatim (13r U3-A, the one source) — so no ticket id, draft marker or process line may
# land in it; anything addressed to HER rides the handoff or the chat draft, never the file (her firm
# rule, 2026-10-29). Sourced by release.sh (the preflight) and make-appcast.sh (the separable road) so
# the two refusals cannot drift (the F2 one-source precedent).
#
#   notes_carry_process_text FILE   → true (0) when the file carries the shape; false (1) when clean.
#
# The shape, each arm probed red on a real offender and green on real public copy:
#   · a ticket id, any case ("vx-669" appears lowercase in this repo's prose);
#   · a line OPENING on Draft/Drafted, optionally after "*" — mid-sentence "drafted" stays legal copy
#     ("a note you drafted on your phone now syncs");
#   · the meta-line phrases every shipped offender carried: "one line per bullet", "her rewrite".
notes_carry_process_text() {
  grep -qiE '\b(vx|vm)-[0-9]|^\*?draft(ed)?\b|one line per bullet|her rewrite' "$1"
}
