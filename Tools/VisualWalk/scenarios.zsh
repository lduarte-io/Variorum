# Tools/VisualWalk/scenarios.zsh — THE SCENARIO TABLE (sourced by visual-walk.sh).
#
# One block per scenario: a `vw_def` row (name · fixture · acts · assertions · expectation) and its
# `scn_<name>` function. To grow the harness, add a block and put the name in SCN_ORDER's place.
# The three rules every block asserts (the 18l U-VIS design note, decision 2, her words):
#   (a) the first visible line and the caret's line move ONLY when the act moves them;
#   (b) the last line's glyph box lies inside its surface — no clipped descenders, no gap;
#   (c) a click lands the caret on the clicked line.
# Every number comes from the app's DEBUG oracle endpoint (`VisualWalkProbe`); captures ride beside.
# `expect` names an OWNED KnownIssues row where the tree is known to fail — asserted honestly: a
# reproduction reports XFAIL with its measured value, a non-reproduction XPASS (re-examine the row).

typeset -gA SCN_TABLE
typeset -ga SCN_ORDER
vw_def() { SCN_ORDER+=($1); SCN_TABLE[$1]="fixture: $2 · acts: $3 · asserts: $4 · expect: $5" }

# Known, OWNED rows the table cites (KnownIssuesAndTechDebt.md):
typeset -g KI_B5='KI row 88 (B5: ⏎ after ⌘↓ on invalidated geometry — FIXED at 18l-b U-B5: the differential road keeps the untouched reading line)'
# (KI_S3 — "the read tier re-wraps under the pointer" — RETIRED at 18l-c U5: the tiers speak one metrics
#  vocabulary, `IndexProseColumn.lines`, and the four XFAILs it labelled are plain assertions again.)

# --- shared scenario helpers -------------------------------------------------------------------------

# Open a note by title and land in Write (the palette is the reliable road).
vw_write_open() {   # title
  vw_open_note "$1"
  if [[ ${PV[mode]} != Write ]]; then
    vw_keys "⌘1 (Write)" 'keystroke "1" using command down'
    vw_settle
  fi
  vw_require '[[ ${PV[mode]} == Write && ${PV[fr]} == editor ]]' "Write with the editor focused on '$1'"
}

# Scroll the Write page by wheel lines at the prose column's middle, then settle.
vw_write_scroll() {  # lines
  local c=(${(s:,:)PV[colX]}) v=(${(s:,:)PV[vis]})
  vw_free_x $c[1] $c[2] $(( v[2] + v[4] / 2 ))
  vw_scroll $FREE_X $(( v[2] + v[4] / 2 )) $1
  vw_settle
}

# The a-rule's pair: the first visible line (offset + y) against a snapshot.
vw_expect_page_still() {   # snapshot label [known]
  vw_expect_eq "$2: first visible line (offset)" "${PV[top]}" "$(vw_get $1 top)" "$3"
  vw_expect_near "$2: first visible line y (pt)" "${PV[topY]}" "$(vw_get $1 topY)" 0.5 "$3"
}

# --- S1: note open → START on the first open, the exact page on a re-open (U0c, R-18l-1) ---------------
vw_def note-reopen "A Case of Identity (first open this run) + A Scandal in Bohemia" \
  "open Case (first) · wheel mid-note · open Scandal · open Case again · ⌥⌘[ · ⌥⌘]" \
  "first open at the start (clip 0, line 0, caret 0); every re-open lands the page she left (line + y)" pass
scn_note-reopen() {
  vw_write_open "A Case of Identity" || return
  vw_cap 01-first-open
  vw_expect_near "first open: page at the top (clip)" "${PV[clip]}" 0 0.5
  vw_expect_eq "first open: first visible line is the note's first" "${PV[top]}" 0
  vw_expect_eq "first open: caret at the start (QUESTIONS #150(a) — the first open seeds no fact; PROVISIONAL)" "${PV[sel]}" "0,0"
  vw_write_scroll 40
  vw_require '(( ${PV[clip]} > 200 ))' "the wheel moved the page mid-note" || return
  vw_snap left; vw_cap 02-left-mid-note
  vw_write_open "A Scandal in Bohemia" || return
  vw_write_open "A Case of Identity" || return
  vw_cap 03-reopen-palette
  vw_expect_page_still left "re-open (palette)"
  vw_keys "⌥⌘[ (back)" 'keystroke "[" using {command down, option down}'
  vw_settle
  vw_keys "⌥⌘] (forward)" 'keystroke "]" using {command down, option down}'
  vw_settle
  vw_cap 04-reopen-history
  vw_expect_page_still left "re-open (history)"
}

# --- S2: typing moves nothing but the caret -----------------------------------------------------------
vw_def write-typing "A Scandal in Bohemia, Write, wheel-scrolled mid-note" \
  "click a mid-page text line · type 3 characters · ⌫ ×3" \
  "(c) the caret on the clicked line; (a) page still, caret line still; every character lands; text restored" pass
scn_write-typing() {
  vw_write_open "A Scandal in Bohemia" || return
  vw_write_scroll 25
  vw_require '[[ -n ${PV[mid]} ]]' "a text line in the viewport's lower half" || return
  local c=(${(s:,:)PV[colX]})
  local y=$(( (PV[midY] + PV[midY1]) / 2 ))
  vw_free_x $(( c[1] + 20 )) $(( c[1] + 160 )) $y; local x=$FREE_X
  vw_click $x $y "a mid-page text line"
  vw_settle; vw_snap before; vw_cap 01-clicked
  vw_expect_between "click: y inside the caret's line box" $y $(( PV[caretY0] - 1 )) $(( PV[caretY1] + 1 ))
  vw_expect_near "click: caret x at the click" "${PV[caretX]}" $x 12
  local sel0=${PV[sel]%%,*} len0=${PV[len]}
  vw_keys "type v" 'keystroke "v"'
  vw_keys "type i" 'keystroke "i"'
  vw_keys "type s" 'keystroke "s"'
  vw_settle; vw_cap 02-typed
  vw_expect_eq "typing: every character landed (length +3)" "${PV[len]}" $(( len0 + 3 ))
  vw_expect_eq "typing: caret advanced 3" "${PV[sel]}" "$(( sel0 + 3 )),0"
  vw_expect_page_still before "typing"
  vw_expect_near "typing: caret line y" "${PV[caretY0]}" "$(vw_get before caretY0)" 0.5
  vw_keys "⌫ ×3" 'key code 51' 'delay 0.3' 'key code 51' 'delay 0.3' 'key code 51'
  vw_settle; vw_cap 03-restored
  vw_expect_eq "restore: length back" "${PV[len]}" $len0
  vw_expect_page_still before "restore"
}

# --- S3: ⏎ then ⌫ at the end of a short note at the page top (U0b, KnownIssues row 87's shape) ----------
vw_def write-newline-roundtrip "About this book (3 blocks, fits the page), Write, page at the top" \
  "click the last line's end · ⏎ (an empty block below) · ⌫ (the carve)" \
  "(a) the first line's y and the page's top air unchanged through both acts; block count 3 → 4 → 3" pass
scn_write-newline-roundtrip() {
  vw_write_open "About this book" || return
  vw_require '(( ${PV[clip]} < 0.5 ))' "the short note rests at its top" || return
  vw_snap top; vw_cap 01-open
  vw_probe last      # the note's end is on screen (a short note) — its last line is asked for
  local c=(${(s:,:)PV[colX]}) blocks=${PV[blk]#*/} len0=${PV[len]}
  local y=$(( PV[lastGlyphY] - 7 ))
  vw_free_x $(( c[2] - 60 )) $(( c[2] - 10 )) $y
  vw_click $FREE_X $y "past the last line's end"
  vw_settle
  vw_require '[[ ${PV[caretEnd]} == 1 ]]' "the caret at the note's end" || return
  vw_keys "⏎" 'key code 36'
  vw_settle; vw_cap 02-return
  vw_expect_eq "⏎: an empty block below" "${PV[blk]}" "$(( blocks + 1 ))/$(( blocks + 1 ))"
  vw_expect_page_still top "⏎"
  vw_expect_near "⏎: the page's top air (clip)" "${PV[clip]}" 0 0.5
  vw_keys "⌫" 'key code 51'
  vw_settle; vw_cap 03-backspace
  vw_expect_eq "⌫: the empty block carved" "${PV[blk]#*/}" $blocks
  vw_expect_eq "⌫: text restored" "${PV[len]}" $len0
  vw_expect_page_still top "⌫"
  vw_expect_near "⌫: the page's top air (clip)" "${PV[clip]}" 0 0.5
}

# --- S4: a divide (⏎ mid-line) and its merge (⌫ at the seam) ------------------------------------------
vw_def write-divide-merge "A Scandal in Bohemia, Write, wheel-scrolled" \
  "click inside a mid-page line · ⏎ (divide) · ⌫ (merge back)" \
  "(a) the page never moves; the caret drops one line on ⏎ and returns on ⌫; blocks +1 then back; text restored" pass
scn_write-divide-merge() {
  vw_write_open "A Scandal in Bohemia" || return
  vw_write_scroll 30
  vw_require '[[ -n ${PV[mid]} ]]' "a text line in the viewport's lower half" || return
  local c=(${(s:,:)PV[colX]})
  local y=$(( (PV[midY] + PV[midY1]) / 2 ))
  vw_free_x $(( c[1] + 40 )) $(( c[1] + 120 )) $y
  vw_click $FREE_X $y "inside a mid-page line"
  vw_settle; vw_snap before; vw_cap 01-clicked
  local blocks=${PV[blk]#*/} len0=${PV[len]} sel0=${PV[sel]}
  vw_require '[[ ${PV[caretEnd]} == 0 ]]' "the caret inside the text" || return
  vw_keys "⏎ (divide)" 'key code 36'
  vw_settle; vw_snap divided; vw_cap 02-divided
  vw_expect_eq "divide: one more block" "${PV[blk]#*/}" $(( blocks + 1 ))
  vw_expect_page_still before "divide"
  local lineH=$(( $(vw_get before caretY1) - $(vw_get before caretY0) ))
  vw_expect_between "divide: the caret moved down onto the new block's first line (pt)" \
    $(( PV[caretY0] - $(vw_get before caretY0) )) $lineH $(( lineH + 30 ))
  vw_expect_eq "divide: the caret at the new block's start (line 0)" "${PV[caretLine]}" 0
  vw_keys "⌫ (merge at the seam)" 'key code 51'
  vw_settle; vw_cap 03-merged
  vw_expect_eq "merge: block count back" "${PV[blk]#*/}" $blocks
  vw_expect_eq "merge: text restored (length)" "${PV[len]}" $len0
  # The cut snaps to a word edge (S4-22), so a mid-word caret divides at the word's end: the caret
  # after the merge belongs at the JOIN — where ⏎ put it — not at the click (first run: 9423 vs 9420).
  vw_expect_eq "merge: the caret at the join (where the divide put it)" "${PV[sel]}" "$(vw_get divided sel)"
  vw_expect_page_still before "merge"
  vw_expect_near "merge: caret line y" "${PV[caretY0]}" "$(vw_get before caretY0)" 0.5
}

# --- S5: a mode round trip (Write → Read → Write) -----------------------------------------------------
vw_def mode-roundtrip "A Scandal in Bohemia, Write, wheel-scrolled, caret on screen" \
  "⌘3 (Read) · ⌘1 (Write)" "(a) the page and the caret come back exactly" pass
scn_mode-roundtrip() {
  vw_write_open "A Scandal in Bohemia" || return
  vw_write_scroll 20
  vw_require '[[ -n ${PV[mid]} ]]' "a text line in the viewport's lower half" || return
  local c=(${(s:,:)PV[colX]}) y=$(( (PV[midY] + PV[midY1]) / 2 ))
  vw_free_x $(( c[1] + 40 )) $(( c[1] + 120 )) $y
  vw_click $FREE_X $y "a mid-page line (caret on screen)"
  vw_settle; vw_snap before; vw_cap 01-write
  vw_keys "⌘3 (Read)" 'keystroke "3" using command down'
  vw_settle; vw_cap 02-read
  vw_expect_eq "Read reached" "${PV[mode]}" Read
  vw_keys "⌘1 (Write)" 'keystroke "1" using command down'
  vw_settle; vw_cap 03-write-again
  vw_expect_eq "Write again" "${PV[mode]}" Write
  vw_expect_page_still before "round trip"
  vw_expect_eq "round trip: caret unchanged" "${PV[sel]}" "$(vw_get before sel)"
  vw_expect_near "round trip: caret line y" "${PV[caretY0]}" "$(vw_get before caretY0)" 0.5
}

# --- S6: a click on a READ-TIER line of the book Index (U0 item 1, KnownIssues row 86) ------------------
# The book Index draws every block at rest as read-cheap text and swaps the clicked one to THE live
# pane. The regression: the caret landed on the block's END — the blank line under the text.
vw_click_read_tier() {  # key(rtI|rtR) label band-top-offset — clicks the LOWEST fully visible multi-line block's LAST
                        # TEXT line, then the block ABOVE it on its FIRST line, asserting (c) each time — and, since
                        # 18l-c U5's rider (her #154 (b)), that the block BELOW each click does not move at all.
  local key=$1 label=$2
  vw_probe rt
  local band_top=$(( WIN_Y + $3 )) band_bot=$(( WIN_Y + WIN_H - 20 ))
  # The oracles keep a row's LAST frame after the lazy column lets the row go (C4 releases a surface's
  # rows only when the surface leaves), so a note whose page scrolled after its first layout carries
  # STALE frames standing over live ones (found at round 1's discriminating run: a 360-pt ghost of a
  # de-realized paragraph over a run of one-line rows). Rows never overlap, so any frame that overlaps
  # another is suspect — both are dropped, and what remains is unambiguous.
  local -a all fit clean; local r o
  all=(${(s:;:)PV[$key]})
  for r in $all; do
    local q=(${(s:,:)r}) clash=0
    for o in $all; do
      [[ $o == $r ]] && continue
      local p=(${(s:,:)o})
      (( q[2] < p[2] + p[4] && p[2] < q[2] + q[4] )) && { clash=1; break }
    done
    (( clash )) && continue
    clean+=($r)
    (( q[2] >= band_top && q[2] + q[4] <= band_bot )) && fit+=($r)
  done
  vw_require '(( ${#fit} >= 2 ))' "two read-tier blocks fully on screen ($key)" || return
  # The lower target is the lowest block of EIGHT or more lines (≥ 200 pt; else 5+, else 3+): tall
  # enough that a regression of the tiers' shared metrics (18l U0's S3, FIXED at 18l-c U5 — the live
  # pane had dropped the tier's 4-pt line spacing, so line k rose ~4k pt) shows on its last line in
  # both voices — a standing tripwire, not a coin toss on block size (round 1: a 5-line block's shift
  # stayed inside its line in Study).
  local low= up= i min
  for min in 200 100 50; do
    low= up=
    for (( i = ${#fit}; i >= 1; i-- )); do
      local q=(${(s:,:)fit[i]})
      if [[ -z $low ]]; then (( q[4] >= min )) && low=$fit[i]
      else up=$fit[i]; break; fi
    done
    [[ -n $low && -n $up ]] && break
  done
  vw_require '[[ -n $low && -n $up ]]' "a multi-line block with one above it ($key)" || return
  local L=(${(s:,:)low}) U=(${(s:,:)up})
  # The block BELOW the lower target (18l-c U5's rider): the nearest clean frame under it, by its id.
  local below= bq
  for r in $clean; do
    bq=(${(s:,:)r})
    (( bq[2] >= L[2] + L[4] - 1 )) || continue
    if [[ -z $below ]] || (( bq[2] < ${${(s:,:)below}[2]} )); then below=$r; fi
  done
  vw_require '[[ -n $below ]]' "a block below the lower target ($key)" || return
  local B=(${(s:,:)below})
  # 1. the LOWER block's LAST TEXT line — her trigger: the line right above the blank separator. Since
  # 18l-c U5's rider the tier DRAWS that stored blank line (#154 (b)), so the frame's bottom is the blank
  # line and her line sits one stored blank line (`blankH`, the probe's own number) above it — the
  # fixture's shape (Sherlock keeps ONE blank line under every paragraph), checked after the click.
  local y=$(( L[2] + L[4] - 8 - PV[blankH] )) x
  vw_free_x $L[1] $(( L[1] + L[3] * 0.5 )) $y; x=$FREE_X
  vw_click $x $y "$label: the last line of a block"
  vw_settle; vw_cap 01-last-line
  # The pane that went live must stand where the frame said the block was (the tiers share their first
  # line's top — 13u2 B): a frame that was a stale ghost is the HARNESS's error, never the product's.
  vw_require '(( abs(PV[topY] - L[2]) <= 12 ))' "the clicked frame was the block's live place (pane top ${PV[topY]} vs frame ${L[2]})" || return
  vw_require '[[ ${PV[nl]} == 1 ]]' "the clicked block is stored over a blank line (the fixture's shape the click aims above)" || return
  vw_assert_last_line_click "$label" $y
  vw_probe rt
  vw_expect_near "$label: the block BELOW the clicked one does not move (18l-c U5's rider)" \
    "$(vw_top_of $key $B[5])" $B[2] 0.5
  # 2. the block ABOVE, on its FIRST line.
  y=$(( U[2] + 8 ))
  vw_free_x $U[1] $(( U[1] + U[3] * 0.5 )) $y; x=$FREE_X
  vw_click $x $y "$label: the first line of the block above"
  vw_settle; vw_cap 02-first-line
  vw_require '(( abs(PV[topY] - U[2]) <= 12 ))' "the clicked frame was the block's live place (pane top ${PV[topY]} vs frame ${U[2]})" || return
  vw_assert_first_line_click "$label" $x $y
  # The ring moved up: the first target went back to rest — and still nothing below moved.
  vw_probe rt
  vw_expect_near "$label: the block below the second click (the first target, back at rest) does not move" \
    "$(vw_top_of $key $L[5])" $L[2] 0.5
  vw_expect_near "$label: the block below the first target does not move through the ring's move" \
    "$(vw_top_of $key $B[5])" $B[2] 0.5
}

# The screen top of the read-tier frame whose block id starts with <id> (the probe's fifth field), from
# the LAST probe; "-" when the frame is not listed (the lib's missing-value mark — a FAIL, never 0).
vw_top_of() {   # key id
  local r q
  for r in ${(s:;:)PV[$1]}; do
    q=(${(s:,:)r})
    [[ $q[5] == $2 ]] && { print -r -- $q[2]; return }
  done
  print -- -
}

# Rule (c) for a click on a block's LAST line, from the probe's answer (PV). Factored so a headless
# pin can feed it planted answers (pins/read-tier-assertions.zsh).
vw_assert_last_line_click() {   # label click-y
  local label=$1 y=$2
  vw_expect_eq "$label last line: a pane went live under the caret" "${PV[fr]}" pane
  vw_expect_eq "$label last line: the caret is NOT on the empty line under the text" \
    "$([[ ${PV[nl]} == 1 && ${PV[caretEnd]} == 1 ]] && print on-the-blank-line || print on-text)" on-text
  # WHICH line (round 1, MINOR-1 — plain, so a wrong-line landing reds): the block's last text line,
  # or the one before it, because the live pane shows the markdown markers the tier hides and can wrap
  # the block one line longer (CONTENT, not a metric — the held 18e's; 18l-c U5 aligned every metric,
  # so a marker-free block lands on exactly `last`). The pre-fix Read ▸ edit landing (line 0) reds.
  local last=$(( PV[caretTextLines] - 1 ))
  # ...in the block's LAST paragraph (round 2, NIT-R2-5): the line count is paragraph-relative, so a
  # multi-paragraph block's first paragraph could satisfy it; the pane holds one block.
  vw_expect_eq "$label last line: the caret in the block's LAST paragraph" "${PV[caretFragLast]}" 1
  vw_expect_between "$label last line: the caret on the block's last text line (or the one a hidden marker's wrap adds)" \
    "${PV[caretLine]}" $(( last - 1 )) $last
  # PLAIN since 18l-c U5 (it was the four S3 XFAILs): the live pane lays the block out with the read
  # tier's own metrics, so the clicked line does not move under the pointer.
  vw_expect_between "$label last line: the clicked line stays under the pointer (click y in its box)" \
    $y $(( PV[caretY0] - 1 )) $(( PV[caretY1] + 1 ))
}

vw_assert_first_line_click() {  # label click-x click-y
  local label=$1 x=$2 y=$3
  vw_expect_eq "$label first line: a pane went live" "${PV[fr]}" pane
  vw_expect_eq "$label first line: the caret in the block's FIRST paragraph" "${PV[caretFragFirst]}" 1
  vw_expect_eq "$label first line: the caret is on the first line" "${PV[caretLine]}" 0
  vw_expect_eq "$label first line: not at the block's end" "${PV[caretEnd]}" 0
  vw_expect_between "$label first line: y inside the caret's line box" $y \
    $(( PV[caretY0] - 1 )) $(( PV[caretY1] + 1 ))
  vw_expect_near "$label first line: caret x at the click" "${PV[caretX]}" $x 12
}

vw_def index-click "The Adventures of Sherlock Holmes ▸ Index, scrolled into A Scandal in Bohemia" \
  "click a block's LAST TEXT line (directly above its stored blank line, drawn since the rider) · click the block above on its FIRST line" \
  "(c) a pane goes live with the caret ON the clicked line — never the blank line; first-line caret under the pointer; the clicked line stays under the pointer (18l-c U5); the block BELOW each click does not move at all (18l-c U5's rider, #154 (b))" \
  pass
scn_index-click() {
  vw_open_note "the adventures of sherlock holmes"
  vw_ax_press index AXButton || { vw_require false "the book's index button"; return }
  vw_settle rt
  vw_require '[[ ${PV[rtI]} != none ]]' "the Index's read tier is drawn" || return
  local c=(${(s:,:)${PV[rtI]%%;*}})
  vw_free_x $c[1] $(( c[1] + c[3] )) $(( WIN_Y + WIN_H / 2 ))
  vw_scroll $FREE_X $(( WIN_Y + WIN_H / 2 )) 12
  vw_settle rt
  vw_click_read_tier rtI Index 70
}

# --- S7: the same click on Read ▸ edit (U0 item 1's second host) -----------------------------------------
vw_def readedit-click "The Red-Headed League ▸ Read ▸ edit (its first open in the pass: no landing scroll, so no stale rows)" \
  "click a block's LAST TEXT line · click the block above on its FIRST line" \
  "(c) and the block below, as the Index" pass
scn_readedit-click() {
  vw_open_note "The Red-Headed League"
  vw_keys "⌘3 (Read)" 'keystroke "3" using command down'
  vw_settle rt
  # (18l U1: the face segments are AXRadioButtons — measured; the AXButton lookup never matched and
  # was latent only because this note opened on edit.)
  if [[ ${PV[face]} != edit ]]; then vw_ax_press edit AXRadioButton; vw_settle rt; fi
  vw_require '[[ ${PV[mode]} == Read && ${PV[face]} == edit ]]' "Read ▸ edit" || return
  # The host space is calibrated on the live pane, which mounts after the rows land.
  local i; for i in {1..16}; do [[ ${PV[rtR]} == (uncal|none) ]] || break; sleep 0.5; vw_probe rt; done
  vw_require '[[ ${PV[rtR]} != uncal && ${PV[rtR]} != none ]]' "the read tier's columns (calibrated on the live pane)" || return
  vw_click_read_tier rtR "Read▸edit" 200
}

# --- S8: the live inline note keeps its whole text through a narrow → restore (U0 item 2) -----------------
vw_def outline-narrow-restore "The Adventures of Sherlock Holmes ▸ Outline, About this book expanded and live" \
  "click into the note · window 1440 → 1100 → 900 → back" \
  "(b) at every width the frame holds the laid-out text exactly (no cut tail, no gap) and the last line's descenders are inside" pass
scn_outline-narrow-restore() {
  vw_open_note "the adventures of sherlock holmes"
  vw_ax_press outline AXButton
  vw_settle
  # The collapsed card is ONE button whose label folds the title and its preview ("About this book,
  # “The Adventures…”"); its ▸ sits 21 pt in, 22 pt down. Expanded, the title is its own text.
  local card t y
  card=($(VIS_AX_MINX=$(( WIN_X + 520 )) VIS_AX_PREFIX=1 $VW_BIN/vis-ax $PID "about this book," AXButton))
  if [[ -n $card ]]; then
    vw_click $(( card[1] + 21 )) $(( card[2] + 22 )) "the card's ▸ (expand inline)"
    vw_settle
  fi
  t=($(VIS_AX_MINX=$(( WIN_X + 520 )) $VW_BIN/vis-ax $PID "about this book" AXStaticText)) \
    || { vw_require false "the expanded About this book note"; return }
  y=$(( t[2] + t[4] + 22 ))
  vw_free_x $(( t[1] + 10 )) $(( t[1] + 300 )) $y
  vw_click $FREE_X $y "into the note's first line"
  vw_settle
  vw_require '[[ ${PV[fr]} == inline ]]' "the expanded note is the live inline editor" || return
  local w0=$WIN_W h0=$WIN_H w n=0
  for w in $w0 1100 900 $w0; do
    [[ $w != $WIN_W ]] && vw_resize $w $h0
    sleep 1.5
    vw_probe measure        # ONE probe: the frame is read before the measure lays anything out
    vw_cap w$w-$(( ++n ))
    vw_expect_near "width $w: the frame holds the laid-out text (frame − measured)" \
      "$(( PV[frameH] - PV[measured] ))" 0 1
    vw_expect_between "width $w: the last line's glyph box inside the frame" \
      "${PV[lastGlyphM]}" 0 "$(( PV[frameH] - PV[insetH] + 0.5 ))"
  done
}

# --- S8b: the LONG live story settles to its laid-out end after a resize (U0 item 2's SECOND mechanism) ---
# U0's (b): TextKit's first full measure after a reflow can be 1–5 % off the layout the next display
# passes settle to (the app: 22,884 pt reported where the story settled at 23,082 once a scroll laid its
# end out), and nothing re-reported — the tail cut, or a blank page above the footer. The settle net
# re-reports on the display pass. A short note cannot show it; the 212-block story does.
vw_def outline-long-story-settle "The Adventures of Sherlock Holmes ▸ Outline, The Adventure of the Copper Beeches live (212 blocks)" \
  "the navigator lands the story live · 1440 → 1000 → 1440 → 1000 → back, scrolled to the story's end each time" \
  "(b) at every width, with the end laid out by the scroll, the frame holds the laid-out text (frame − laid-out bottom ±1 pt) and the end is on screen" pass
scn_outline-long-story-settle() {
  vw_open_note "the adventures of sherlock holmes"
  vw_ax_press outline AXButton
  vw_settle
  local nav; nav=($($VW_BIN/vis-ax $PID "⠿, the adventure of the copper beeches" AXButton)) \
    || { vw_require false "the navigator's Copper Beeches row"; return }
  vw_click $(( nav[1] + 80 )) $(( nav[2] + nav[4] / 2 )) "the navigator: The Adventure of the Copper Beeches"
  vw_settle
  if [[ ${PV[fr]} != inline ]]; then   # the landing did not make it live: click its first line
    local t; t=($(VIS_AX_MINX=$(( WIN_X + 520 )) $VW_BIN/vis-ax $PID "the adventure of the copper beeches" AXStaticText)) \
      || { vw_require false "the expanded story's title"; return }
    local y=$(( t[2] + t[4] + 22 ))
    vw_free_x $(( t[1] + 10 )) $(( t[1] + 300 )) $y
    vw_click $FREE_X $y "into the story's first line"
    vw_settle
  fi
  vw_require '[[ ${PV[fr]} == inline ]] && (( ${PV[len]} > 40000 ))' "the long story is the live inline editor" || return
  local w0=$WIN_W h0=$WIN_H w n=0
  for w in 1000 $w0 1000 $w0; do
    vw_resize $w $h0
    sleep 1.5
    vw_free_x $(( WIN_X + 600 )) $(( WIN_X + WIN_W - 60 )) $(( WIN_Y + WIN_H / 2 ))
    vw_scroll $FREE_X $(( WIN_Y + WIN_H / 2 )) 300          # to the book's end — the story's end
    sleep 1.5
    vw_probe last            # NO measure: the laid-out bottom the scroll produced, read O(1)
    vw_cap w$w-$(( ++n ))
    vw_expect_near "width $w: the frame holds the settled layout (frame − laid-out bottom − inset)" \
      "$(( PV[frameH] - PV[lastFrag] - PV[insetH] ))" 0 1
    vw_expect_between "width $w: the story's last line is on screen (its glyph box drawn)" \
      "${PV[lastGlyphY]}" $WIN_Y $(( WIN_Y + WIN_H ))
  done
}

# --- S9: B5 — ⏎ right after a ⌘↓ landing on invalidated geometry (KnownIssues row 88) ---------------------
vw_def b5-return-after-cmd-down "A Scandal in Bohemia, Write" \
  "a blank line mid-page · ⏎ + ⌫ (the carve's full re-render invalidates layout) · ⌘↓ · ⏎ at the tail · ⌫" \
  "(a) the ⏎ at the tail must not move the page (the lines above the caret)" \
  "pass — $KI_B5. HISTORY: U0b measured +109/+166 on 998f7d7d; U-VIS reproduced it in the FULL Study pass (the lines above the caret slid under an unmoved clip); 18l-b U-B5 traced it (TextKit re-bases a viewport that floats on estimates when a layout-forcing read lays out the new paragraph — +438.8/+662.4 pt measured on this recipe) and fixed it. PLAIN in both voices since: a move here is a FAIL"
scn_b5-return-after-cmd-down() {
  vw_write_open "A Scandal in Bohemia" || return
  vw_write_scroll 30
  # U0b's walk, exactly: a BLANK line mid-page (a block's end in a note that keeps the blank line
  # between paragraphs) → ⏎ (an empty block below) → ⌫ (A7's carve, which lands through the FULL
  # re-render — the invalidation B5 needs) → ⌘↓ → ⏎ at the tail.
  vw_require '[[ -n ${PV[blank]} ]]' "a blank line in the viewport's lower half" || return
  local c=(${(s:,:)PV[colX]}) y=$(( (PV[blankY] + PV[blankY1]) / 2 )) len0=${PV[len]}
  vw_free_x $(( c[1] + 20 )) $(( c[1] + 200 )) $y
  vw_click $FREE_X $y "a blank line mid-page (a block's end)"
  vw_settle
  local blocks0=${PV[blk]#*/}
  vw_keys "⏎ (an empty block below)" 'key code 36'
  vw_settle
  vw_require '[[ ${PV[blk]#*/} == $(( blocks0 + 1 )) ]]' "⏎ at the block's end minted an empty block" || return
  vw_keys "⌫ (the carve → the full re-render)" 'key code 51'
  vw_settle
  vw_require '[[ ${PV[len]} == $len0 ]]' "the mid-note round trip restored the text" || return
  vw_keys "⌘↓" 'key code 125 using command down'
  vw_settle; vw_snap tail; vw_cap 01-cmd-down
  local blocks=${PV[blk]#*/}
  vw_require '[[ ${PV[caretEnd]} == 1 ]]' "⌘↓ put the caret at the end" || return
  vw_keys "⏎ at the tail" 'key code 36'
  vw_settle; vw_cap 02-return
  vw_expect_eq "⏎ at the tail: an empty block below" "${PV[blk]#*/}" $(( blocks + 1 ))
  # PLAIN in both voices (18l-b U-B5): the KNOWN label it carried in Study (U-VIS round 1, MINOR-2 —
  # where it reproduced, every full pass) is retired with the fix — the differential road now keeps the
  # untouched reading line (`keepUntouchedReadingLine`), measured XPASS on this recipe and red again on
  # the fix's revert (R-keep, a scratch build), so a move here is a regression and must FAIL.
  vw_expect_page_still tail "⏎ at the tail"
  vw_keys "⌫ (restore)" 'key code 51'
  vw_settle; vw_cap 03-restored
  vw_expect_eq "restore: text back" "${PV[len]}" $len0
}

# --- S10: B5's re-font road — ⏎ after ⌘↓ when a whole-document RE-FONT invalidated the layout ----------
vw_def b5-refont "A Scandal in Bohemia, Write" \
  "a voice switch (the whole-document re-font) · ⌘↓ · ⏎ at the tail · ⌫ · the voice switched back" \
  "(a) the ⏎ at the tail must not move the page" \
  "pass — $KI_B5's re-font road (U0b named it) never reproduced at U-VIS, so it is asserted PLAIN (round 1, MINOR-2): a move here is a FAIL"
scn_b5-refont() {
  vw_write_open "A Scandal in Bohemia" || return
  local here=${PV[voice]} other len0=${PV[len]}
  [[ $here == terminal ]] && other=study || other=terminal
  vw_set_voice $other
  vw_settle
  vw_require '[[ ${PV[mode]} == Write && ${PV[fr]} == editor ]]' "back in Write after Settings" || { vw_set_voice $here; return }
  vw_keys "⌘↓" 'key code 125 using command down'
  vw_settle; vw_snap tail; vw_cap 01-refont-cmd-down
  local blocks=${PV[blk]#*/}
  vw_keys "⏎ at the tail" 'key code 36'
  vw_settle; vw_cap 02-return
  vw_expect_eq "⏎ at the tail: an empty block below" "${PV[blk]#*/}" $(( blocks + 1 ))
  vw_expect_page_still tail "⏎ at the tail (after a re-font)"
  vw_keys "⌫ (restore)" 'key code 51'
  vw_settle
  vw_expect_eq "restore: text back" "${PV[len]}" $len0
  vw_set_voice $here
}

# --- S11: note Read's deep landing arrives at its anchor and holds (18l U1 — the F3 shape on note Read) ---
# The deep click is the contents column's own road: filter the column to ONE block by a word only that
# block holds, click its row — the face lands it. The fixture's words are unique to their blocks in the
# sample library's *A Scandal in Bohemia* (262 blocks; checked against `SherlockAdventures.txt`, whole
# story, case-insensitive substring): 209 "substitution", 123 "inextricable", 245 "superscribed".
# Each face's FIRST click is cold (its column freshly mounted in a fresh launch; nothing below the
# first screen ever drawn); the rest are warm. Measured two ways: the probe's `rl` (the landed block
# against its face's SHIPPED anchor — edit centred, read at 0.08) at +1.5 s (logged) and +6 s
# (asserted), and the SHIPPING signpost her Console reads (`landing surface=ReadNote…` — the health
# review §1.2's diagnostic: note Read used to emit NOTHING).
vw_def read-landing "A Scandal in Bohemia ▸ Read, BOTH faces, deep clicks through the contents column's filter" \
  "edit: 209 (cold) · 123 (a second, never-drawn region) · 209 (warm) · read: 245 (cold) · 123 · 245 (warm)" \
  "each landed block rests at its face's anchor (±3 pt) 6 s after the click; each landing's signpost says end=settled" pass
typeset -gA RL_WORD=(209 substitution 123 inextricable 245 superscribed)

# The signpost her Console reads for the landing just made (the last `end=` line of the window).
vw_read_signpost() {   # seconds-back
  /usr/bin/log show --last ${1}s --style compact \
    --predicate 'eventMessage CONTAINS "landing surface=ReadNote"' 2>/dev/null \
    | grep -o 'landing surface=ReadNote.*end=[a-z]* top=-\{0,1\}[0-9]*' | tail -1
}

vw_read_deep_click() {   # face ordinal tag
  local face=$1 ord=$2 tag=$3 word=${RL_WORD[$2]}
  local lens; lens=($($VW_BIN/vis-ax $PID "⌕" AXStaticText)) \
    || { vw_require false "the contents column's filter (its ⌕)"; return 1 }
  vw_click $(( lens[1] + lens[3] + 40 )) $(( lens[2] + lens[4] / 2 )) "the column's filter field"
  vw_keys "select the filter's text" 'keystroke "a" using command down'
  vw_keys "type: $word" "keystroke \"$word\""
  sleep 1.2
  local row; row=($($VW_BIN/vis-ax $PID "$ord" AXStaticText)) \
    || { vw_require false "the filtered column row $ord"; return 1 }
  (( row[1] < WIN_X + 700 )) || { vw_require false "row $ord is the COLUMN's (x ${row[1]})"; return 1 }
  local t0=$EPOCHSECONDS
  vw_click $(( row[1] + row[3] + 60 )) $(( row[2] + row[4] / 2 )) "row $ord (block $ord, $tag)"
  sleep 1.5
  vw_probe rl; vw_cap $face-$ord-$tag-1s5
  vw_log "  $face $ord ($tag) +1.5 s: rl=${PV[rl]} rlH=${PV[rlH]} rlVis=${PV[rlVis]}"
  sleep 4.5
  vw_probe rl; vw_cap $face-$ord-$tag-6s
  vw_expect_near "$face ▸ block $ord ($tag): at its anchor 6 s after the click (pt)" "${PV[rl]}" 0 3
  local sp; sp=$(vw_read_signpost $(( EPOCHSECONDS - t0 + 3 )))
  vw_log "  signpost: ${sp:-none}"
  vw_expect_eq "$face ▸ block $ord ($tag): the signpost [${sp:-none}]" "${${(M)sp:#*end=settled*}:+settled}" settled
}

scn_read-landing() {
  vw_open_note "A Scandal in Bohemia"
  vw_keys "⌘3 (Read)" 'keystroke "3" using command down'
  vw_settle rl
  vw_require '[[ ${PV[mode]} == Read ]]' "Read on A Scandal in Bohemia" || return
  local face ord tag
  # RL_FACES orders the faces (default edit,read): each run's FIRST face is the truly cold one — the
  # second arrives after the face switch has already landed its parked block (a partly warm column).
  for face in ${(s:,:)${RL_FACES:-edit,read}}; do
    if [[ ${PV[face]} != $face ]]; then
      # The face switch's segments are AXRadioButtons (measured); "read" is also the sidebar's mode
      # row item, which sits left of the Read host — so only matches right of the sidebar count.
      export VIS_AX_MINX=$(( WIN_X + 300 ))
      vw_ax_press $face AXRadioButton
      unset VIS_AX_MINX
      vw_settle rl
    fi
    vw_require '[[ ${PV[face]} == $face ]]' "Read ▸ $face" || return
    sleep 2
    local -a plan
    [[ $face == edit ]] && plan=(209:cold 123:second 209:warm) || plan=(245:cold 123:second 245:warm)
    local step
    for step in $plan; do
      vw_read_deep_click $face ${step%%:*} ${step#*:} || return
    done
  done
}

# --- S13: the Takes article's landing, WATCHED by the one authority (18l-b U2) ------------------------
# The Takes article's landings now file the shipping signpost (`landing surface=TakesArticle …` — the
# surface never had one) and END when they settle. Six rows, in her rulings' terms: U0c's first open in
# Takes (the top, NO landing asked, so no line); the N9 entry landing on a deep current block (revealed,
# `end=settled`); R-Q21's plain round trip (it STANDS DOWN — no line; the page she left); R-Q20's landing
# wins (the current block moved while away → the landing outranks the memory: the page opens at the top,
# `target=0 … end=settled`); HER SCROLL inside the hold ends a landing (`end=handedover`); and the fan
# panel's bloom door (17o row 8 — `Open Takes mode`, a bloom landing, never weighed against the memory).
# The row A precondition is a real FIRST open in Takes: when the note's remembered mode is not Takes, the
# scenario leaves it in Takes and relaunches (a new run) — so it is self-contained in any pass.
vw_def takes-landing "A Scandal in Bohemia, first open this run in Takes (its remembered mode — staged by a relaunch when needed)" \
  "first open (Takes) · ⌘1 · ⌘↓ · ⌘2 · ⌘1 · ⌘2 · ⌘1 · ⌘↑ · ⌘2 · ⌘1 · ⌘↓ · ⌘2 + her wheel 0.7 s later · ⌘1 · ⌘⇧T · Open Takes mode" \
  "the first open asks no landing (no TakesArticle line); the entry landing, R-Q20's win and the bloom each file end=settled; R-Q21's round trip files nothing; her wheel inside the hold files end=handedover" pass

# Every TakesArticle signpost in the last N seconds (the shipping line, content-free).
vw_takes_signposts() {   # seconds-back
  /usr/bin/log show --last ${1}s --style compact \
    --predicate 'eventMessage CONTAINS "landing surface=TakesArticle"' 2>/dev/null \
    | grep -o 'landing surface=TakesArticle.*end=[a-z]* top=-\{0,1\}[0-9]*'
}

# The lines filed since t0 (with a second of slack for the log's delivery).
vw_takes_since() {   # t0 → TK_LINES (array) + TK_LAST
  sleep 1.5
  TK_LINES=("${(@f)$(vw_takes_signposts $(( EPOCHSECONDS - $1 + 1 )))}")
  TK_LINES=(${TK_LINES:#})
  TK_LAST=${TK_LINES[-1]:-}
  local l; for l in $TK_LINES; do vw_log "  signpost: $l"; done
  (( ${#TK_LINES} )) || vw_log "  signpost: none"
}
typeset -ga TK_LINES; typeset -g TK_LAST=

# "settled" when the line is a settled landing on the note's LAST block (target = rows − 1).
vw_takes_on_last() {   # line
  local rows=${${1##*rows=}%% *} target=${${1##*target=}%% *}
  [[ $1 == *end=settled* && -n $rows && $target == $(( rows - 1 )) ]] && print settled
}

vw_takes_mode() {   # 1|2 → ⌘1 / ⌘2, settled
  vw_keys "⌘$1" "keystroke \"$1\" using command down"
  sleep 1.2
  vw_settle
}

scn_takes-landing() {
  local t0
  # Row A — U0c: the session's FIRST open of the note, in its remembered mode (Takes): the top, no landing.
  vw_open_note "A Scandal in Bohemia"
  if [[ ${PV[mode]} != Takes ]]; then
    vw_log "  the note's remembered mode is ${PV[mode]} — leaving it in Takes and relaunching (a new run)"
    vw_takes_mode 2
    vw_quit_app; sleep 2; vw_launch
    vw_open_note "A Scandal in Bohemia"
  fi
  vw_require '[[ ${PV[mode]} == Takes ]]' "the first open this run lands in Takes (the note's remembered mode)" || return
  t0=$EPOCHSECONDS; sleep 2; vw_cap 01-first-open-in-takes
  vw_takes_since $(( t0 - 6 ))
  vw_expect_eq "A · the first open in Takes asks NO landing (U0c's opening arm): TakesArticle lines" ${#TK_LINES} 0

  # Row B — the N9 entry landing on a deep current block: revealed at the page's edge, watched, settled.
  vw_takes_mode 1
  vw_keys "⌘↓ (the caret to the note's end — the current block is the last)" 'key code 125 using command down'
  vw_settle
  t0=$EPOCHSECONDS
  vw_takes_mode 2
  sleep 2.5; vw_cap 02-entry-landing-deep
  vw_takes_since $t0
  vw_expect_eq "B · the entry landing on the LAST block is watched and SETTLES [${TK_LAST:-none}]" "$(vw_takes_on_last "$TK_LAST")" settled

  # Row C — R-Q21's plain round trip: the entry landing stands down; nothing is filed; the page she left.
  vw_takes_mode 1
  t0=$EPOCHSECONDS
  vw_takes_mode 2
  sleep 2.5; vw_cap 03-plain-round-trip
  vw_takes_since $t0
  vw_expect_eq "C · R-Q21's plain round trip STANDS DOWN: TakesArticle lines since the return" ${#TK_LINES} 0
  if cmp -s $SCN_DIR/02-entry-landing-deep.png $SCN_DIR/03-plain-round-trip.png; then
    vw_log "  C · evidence: the round trip's capture is BYTE-IDENTICAL to the landed page's (cmp)"
  else
    vw_log "  C · evidence: the two captures differ in bytes (cmp) — read them (the caret's blink, the ring)"
  fi

  # Row D — R-Q20's landing wins: the current block moved to the first while away; the page opens at the TOP.
  vw_takes_mode 1
  vw_keys "⌘↑ (the caret to the note's start — the current block is the first)" 'key code 126 using command down'
  vw_settle
  t0=$EPOCHSECONDS
  vw_takes_mode 2
  sleep 2.5; vw_cap 04-landing-wins-at-the-top
  vw_takes_since $t0
  vw_expect_eq "D · R-Q20: the landing outranks the memory and settles at once on the first block [${TK_LAST:-none}]" "${${(M)TK_LAST:#*target=0*hops=0*end=settled*}:+settled}" settled

  # Row E — HER wheel inside the landing's hold ends it (ONE guarded act: ⌘2, then 0.35 s, then her wheel).
  vw_takes_mode 1
  vw_keys "⌘↓ (the caret to the end again)" 'key code 125 using command down'
  vw_settle
  local x=$(( WIN_X + WIN_W * 6 / 10 )) y=$(( WIN_Y + WIN_H / 2 ))
  vw_act_note "⌘2 then HER wheel 0.7 s later at ($x,$y) — one guarded act"
  vw_step $x $y
  vw_no_foreign_at $x $y
  vw_our_window_is_key
  t0=$EPOCHSECONDS
  osascript -e 'tell application "System Events" to keystroke "2" using command down' >/dev/null
  # 0.7 s: after the board has mounted and taken its landing (the watch begins at the landing's first
  # decided step), inside the watch's one-second hold.
  sleep 0.7
  $VW_BIN/walk-scroll $x $y -3 >/dev/null
  sleep 2.5; vw_settle; vw_cap 05-her-wheel-hands-over
  vw_takes_since $t0
  vw_expect_eq "E · her wheel inside the hold hands the landing over [${TK_LAST:-none}]" "${${(M)TK_LAST:#*end=handedover*}:+handedover}" handedover

  # Row F — the fan panel's bloom door (17o row 8): Write's takes panel on the caret's block → Open Takes mode.
  vw_takes_mode 1
  vw_keys "⌘⇧T (the takes panel on the caret's block)" 'keystroke "t" using {command down, shift down}'
  sleep 1.5
  t0=$EPOCHSECONDS
  vw_ax_press "Open Takes mode" AXButton || { vw_require false "the takes panel's Open Takes mode door"; return }
  sleep 3; vw_settle; vw_cap 06-bloom-door
  vw_require '[[ ${PV[mode]} == Takes ]]' "the bloom door switched to Takes" || return
  vw_takes_since $t0
  vw_expect_eq "F · the bloom door's landing on the LAST block is watched and settles [${TK_LAST:-none}]" "$(vw_takes_on_last "$TK_LAST")" settled
}

# --- S14: the BOOK's landings at 18l-b U4 ----------------------------------------------------------------
# Item 1: the Outline's landing ends WITH the Outline (R2-12 parity) — a mode switch inside its one-second
# hold used to leave the authority (BookView's @State) armed, so it filed `landing surface=BookOutline …
# end=settled` for a surface already gone. Item 2 (#153): a Read ▸ Scroll click-through lands in the Index
# with the clicked block live and its caret at the block's START — it used to park at the END, the blank
# line under the text (U0's sweep S4). Item 3 (D1): the flow's stories stand at the manifest's own
# heights — its landings settle on them. Row A's zero-line claim has TWO controls, so it cannot pass
# vacuously: the Index's landing proves the navigator click took (its target is the story's row), and
# a plain navigator landing back in Outline proves the log read sees BookOutline lines at all.
vw_def book-landings "The Adventures of Sherlock Holmes ▸ The Copper Beeches (the book's last story) + The Beryl Coronet" \
  "Outline: Copper Beeches' navigator row, then Index 0.3 s later (one guarded act) · Outline · Beryl Coronet's navigator row (the control) · Read (Scroll — the carry lands Beryl Coronet) · click its third paragraph · Read · a long wheel" \
  "A: a landing its mode switch ended files NO BookOutline line (the Index's landing lands the story; the control settles); B: the flow's landing settles; C: the click-through's live pane holds its caret at the block's START, never on the blank line under its text" pass

# Every signpost of <surface> in the last N seconds (the shipping line, content-free).
vw_book_signposts() {   # surface seconds-back → BS_LINES (array) + BS_LAST
  sleep 1.5
  BS_LINES=("${(@f)$(/usr/bin/log show --last ${2}s --style compact \
    --predicate "eventMessage CONTAINS \"landing surface=$1 \"" 2>/dev/null \
    | grep -o "landing surface=$1 .*end=[a-z]* top=-\{0,1\}[0-9]*")}")
  BS_LINES=(${BS_LINES:#})
  BS_LAST=${BS_LINES[-1]:-}
  local l; for l in $BS_LINES; do vw_log "  signpost: $l"; done
  (( ${#BS_LINES} )) || vw_log "  signpost ($1): none"
}
typeset -ga BS_LINES; typeset -g BS_LAST=

scn_book-landings() {
  local t0 nav x y
  vw_open_note "the adventures of sherlock holmes"
  vw_ax_press outline AXButton
  vw_settle
  nav=($($VW_BIN/vis-ax $PID "⠿, the adventure of the copper beeches" AXButton)) \
    || { vw_require false "the navigator's Copper Beeches row"; return }

  # Row A — ONE guarded act: the navigator's row (focus + reveal: an Outline landing), then the book's
  # Index 0.3 s after the last click — inside the landing's one-second hold, so it cannot have finished
  # on its own. The row is clicked TWICE, 0.8 s apart (the walker fact: a single click is sometimes
  # swallowed by the activation — measured here in Study; the act is idempotent, and the second
  # landing supersedes the first silently).
  x=$(( nav[1] + 80 )) y=$(( nav[2] + nav[4] / 2 ))
  vw_act_note "the navigator's Copper Beeches row (twice), then Index 0.3 s later — one guarded act"
  vw_step $x $y
  vw_no_foreign_at $x $y
  vw_our_window_is_key
  t0=$EPOCHSECONDS
  cliclick c:$x,$y
  sleep 0.8
  cliclick c:$x,$y
  sleep 0.3
  $VW_BIN/vis-ax $PID index AXButton press >> $RUN_DIR/run.log \
    || { vw_require false "the book's index button"; return }
  sleep 5.5; vw_settle; vw_cap 01-outline-landing-ended-by-index
  vw_book_signposts BookIndex $(( EPOCHSECONDS - t0 + 1 ))
  local rows=${${BS_LAST##*rows=}%% *} target=${${BS_LAST##*target=}%% *}
  vw_require '[[ -n $rows && $target == $(( rows - 1 )) ]]' \
    "the navigator click took: the Index landed the book's LAST story [${BS_LAST:-none}]" || return
  vw_book_signposts BookOutline $(( EPOCHSECONDS - t0 + 1 ))
  vw_expect_eq "A · the Outline's landing ended WITH the Outline: BookOutline lines since the click" ${#BS_LINES} 0

  # Row A's control — back in Outline, a plain navigator landing (no switch) files its line. Another
  # story's row: a FOCUSED note's row wears the voice's selection marker in its label (Terminal's is
  # non-empty — measured), so Copper Beeches' own row no longer answers to its bare name.
  vw_ax_press outline AXButton
  vw_settle
  nav=($($VW_BIN/vis-ax $PID "⠿, the adventure of the beryl coronet" AXButton)) \
    || { vw_require false "the navigator's Beryl Coronet row (the control)"; return }
  t0=$EPOCHSECONDS
  vw_click $(( nav[1] + 80 )) $(( nav[2] + nav[4] / 2 )) "the navigator's Beryl Coronet row (the control)"
  sleep 3; vw_settle; vw_cap 02-outline-control-landing
  vw_book_signposts BookOutline $(( EPOCHSECONDS - t0 + 1 ))
  vw_expect_eq "A · control: a landing the Outline keeps files end=settled [${BS_LAST:-none}]" \
    "${${(M)BS_LAST:#*end=settled*}:+settled}" settled

  # Row B — Read ▸ Scroll: the carry lands the story on the flow's manifest heights.
  t0=$EPOCHSECONDS
  export VIS_AX_MINX=$(( WIN_X + 300 ))
  vw_ax_press read AXButton || { unset VIS_AX_MINX; vw_require false "the book's read button"; return }
  unset VIS_AX_MINX
  sleep 3; vw_settle; vw_cap 03-read-scroll-landed
  vw_book_signposts ReadingFlow $(( EPOCHSECONDS - t0 + 1 ))
  vw_expect_eq "B · the flow's landing settles [${BS_LAST:-none}]" "${${(M)BS_LAST:#*end=settled*}:+settled}" settled

  # Row C — the click-through: the landed story's (Beryl Coronet's — the control focused it, so the
  # carry landed it) third paragraph, a block over her blank line.
  local p; p=($(VIS_AX_PREFIX=1 VIS_AX_MINX=$(( WIN_X + 300 )) $VW_BIN/vis-ax $PID "he was a man of about fifty" AXStaticText)) \
    || { vw_require false "the story's third paragraph on the flow's page"; return }
  vw_require '(( p[2] > WIN_Y + 60 && p[2] + 20 < WIN_Y + WIN_H ))' "the third paragraph is on screen (y ${p[2]})" || return
  x=$(( p[1] + (p[3] > 400 ? 200 : p[3] / 2) )) y=$(( p[2] + (p[4] > 40 ? 12 : p[4] / 2) ))
  t0=$EPOCHSECONDS
  vw_click $x $y "the third paragraph's first line (the click-through)"
  sleep 3; vw_settle; vw_cap 04-click-through-caret
  vw_book_signposts BookIndex $(( EPOCHSECONDS - t0 + 1 ))
  vw_require '[[ ${PV[fr]} == pane ]]' "the click-through made a pane live under the keyboard" || return
  vw_require '[[ ${PV[nl]} == 1 ]]' "the landed block carries her blank line (ends in a newline)" || return
  vw_expect_eq "C · the caret is NOT on the empty line under the text" \
    "$([[ ${PV[nl]} == 1 && ${PV[caretEnd]} == 1 ]] && print on-the-blank-line || print on-text)" on-text
  vw_expect_eq "C · the caret at the landed block's START (#153)" "${PV[sel]}" "0,0"
  vw_expect_eq "C · …on its first line, in its first paragraph" "${PV[caretLine]}/${PV[caretFragFirst]}" "0/1"

  # Row D — back to the flow, a long wheel: the page holds still once the scroll stops (evidence).
  t0=$EPOCHSECONDS
  export VIS_AX_MINX=$(( WIN_X + 300 ))
  vw_ax_press read AXButton || { unset VIS_AX_MINX; vw_require false "the book's read button"; return }
  unset VIS_AX_MINX
  sleep 3; vw_settle
  vw_book_signposts ReadingFlow $(( EPOCHSECONDS - t0 + 1 ))
  vw_expect_eq "D · the flow's landing (the carry back) settles [${BS_LAST:-none}]" "${${(M)BS_LAST:#*end=settled*}:+settled}" settled
  x=$(( WIN_X + WIN_W * 6 / 10 )) y=$(( WIN_Y + WIN_H / 2 ))
  vw_scroll $x $y -60
  sleep 1.5; vw_cap 05-flow-after-wheel
  sleep 2; vw_cap 06-flow-two-seconds-later
  if cmp -s $SCN_DIR/05-flow-after-wheel.png $SCN_DIR/06-flow-two-seconds-later.png; then
    vw_log "  D · evidence: the page two seconds after the wheel is BYTE-IDENTICAL (cmp) — nothing moved"
  else
    vw_log "  D · evidence: the two captures differ in bytes (cmp) — read them"
  fi
}

# --- S15: SEARCH IN TAKES (18l-c U7 — her R-18l-6; find-only v1, R-18l-9; the off-scope arrival, R-18l-10)
# The unit's walk, made standing (18l-b U2's precedent). takemania — the Jekyll book's worked note, many
# blocks, several fanned — searched for "Hyde". The probe reads the bar's own face (`tf` its count, `tfs` the
# scope, `tfo` the current match off-scope, `tmk` the margin markers drawn) and the LIVE pane a step landed
# (`tsel` / `tvis` / `trole`) — reported apart from `fr`/`sel`, because while ⏎ steps the FIELD holds the
# keyboard (the Write bar's convention, decision 1). Mutates nothing lasting: the one keystroke is undone.
vw_def takes-find "takemania (The Strange Case of Dr Jekyll and Mr Hyde — seeded; Help ▸ Restore makes it), Takes" \
  "⌘2 · ⌘F · type Hyde · ⏎ · ⏎⏎ · ⇧⏎ back · the scope chip OFF · ⏎ to the first off-scope match · Esc · type X · ⌘Z · ⌘G from the board · the chip back ON" \
  "⌘F: the field holds the keyboard; a count; ⏎: 1 of N, the take live with the 4-letter match selected and on screen, the field KEEPS the keyboard; ⏎⏎: 3 of N; ⇧⏎: 2 of N, back, the field still holding (R1-N4 — provable only against live hardware modifiers); OFF: the count grows and the scope says so; a step reaches a take its block is not showing — a FAN card, live, match selected; Esc: the keyboard to the take, the match still selected; X replaces it (len −3), ⌘Z restores; ⌘G from the board: the landed take holds the keyboard" pass

scn_takes-find() {
  vw_open_note "takemania"
  vw_require '[[ ${PV[post]} != none ]]' "takemania opened (the Jekyll book is seeded — Help ▸ Restore makes it)" || return
  vw_takes_mode 2
  vw_require '[[ ${PV[mode]} == Takes ]]' "the note is in Takes" || return

  # Row A — ⌘F opens the bar; its field holds the keyboard.
  vw_keys "⌘F (find in this note's takes)" 'keystroke "f" using command down'
  sleep 1; vw_settle
  vw_expect_eq "A · ⌘F in Takes opens the board's find bar (its count face is on screen)" "${PV[tf]:+open}" open
  vw_expect_eq "A · the find FIELD holds the keyboard (a text field — not a pane, not the editor)" "${PV[fr]}" text
  vw_expect_eq "A · 'only chosen takes' is ON by default (her ruling)" "${PV[tfs]}" 1
  vw_cap 01-bar-open

  # Row B — type Hyde: counted over the chosen takes, nothing navigated yet (incremental navigation off).
  vw_keys "type: Hyde" 'keystroke "Hyde"'
  sleep 1; vw_settle
  local total=${${PV[tf]%%_match*}}
  vw_log "  B · the count face: ${PV[tf]}"
  vw_require '[[ $total == <-> ]] && (( total > 3 ))' "takemania's chosen takes hold several Hyde matches (${PV[tf]})" || return
  vw_cap 02-hyde-counted

  # Row C — ⏎: the first match's take goes LIVE, the match SELECTED and on screen; the field keeps the keyboard.
  vw_keys "⏎ (find next, from the field)" 'key code 36'
  sleep 2.5; vw_settle
  vw_expect_eq "C · ⏎: the count says 1 of $total" "${PV[tf]}" "1_of_$total"
  vw_expect_eq "C · the landed take is LIVE with a 4-letter match SELECTED (tsel=${PV[tsel]:-none})" "${${PV[tsel]:-,}#*,}" 4
  vw_expect_eq "C · …and on screen (its row revealed)" "${PV[tvis]:-0}" 1
  vw_expect_eq "C · the FIELD keeps the keyboard, so ⏎ steps again" "${PV[fr]}" text
  vw_cap 03-first-match-live-selected

  # Row D — two more ⏎.
  vw_keys "⏎" 'key code 36'; sleep 1.5
  vw_keys "⏎" 'key code 36'; sleep 2.5; vw_settle
  vw_expect_eq "D · ⏎⏎: the count says 3 of $total" "${PV[tf]}" "3_of_$total"
  vw_expect_eq "D · the third match's take is live, its match selected" "${${PV[tsel]:-,}#*,}" 4
  vw_cap 04-third-match

  # Row D2 — ⇧⏎ steps BACK (the ladder's R1-N4 + its sanity item's fix). The bar reads the ⇧ off
  # the EVENT that fired the submit (`NSApp.currentEvent` — the Return keyDown carries what was
  # pressed WITH it), so even a ⇧ RELEASED before the app processes the ⏎ steps back — which is
  # exactly what System Events' transient `using shift down` posts (down·key·up faster than the
  # app dequeues; a human's quick ⇧-tap or a macro is the same shape). **THIS ROW IS THE
  # RED-ON-OLD:** on the live-state read (`NSEvent.modifierFlags`) it measured 4_of_23 — the step
  # went FORWARD (run 090640; revert-verified at the ladder's sanity act).
  vw_keys "⇧⏎ (find previous — the transient ⇧, the quick tap's own shape)" 'key code 36 using shift down'
  sleep 2.5; vw_settle
  vw_expect_eq "D2 · ⇧⏎ steps back: the count says 2 of $total" "${PV[tf]}" "2_of_$total"
  vw_expect_eq "D2 · the previous match's take is live, its match selected" "${${PV[tsel]:-,}#*,}" 4
  vw_expect_eq "D2 · the FIELD keeps the keyboard through ⇧⏎" "${PV[fr]}" text
  vw_cap 04b-shift-return-back
  # …and one ⏎ forward so every row after D2 walks the SHIPPED path (F's off-scope arrival is
  # path-sensitive — run 090640's F).
  vw_keys "⏎ (forward again — the shipped path resumes)" 'key code 36'
  sleep 1.5; vw_settle
  vw_expect_eq "D2 · ⏎ resumes forward: 3 of $total" "${PV[tf]}" "3_of_$total"

  # Row E — the scope chip OFF: every live take is searched; the count grows; the margins say where.
  vw_takes_find_press_chip on || { vw_require false "the scope chip turned the scope off (tfs=${PV[tfs]})"; return }
  sleep 1; vw_settle
  local face=${PV[tf]} every
  if [[ $face == *_of_* ]]; then every=${${face#*_of_}%%_*}; else every=${face%%_match*}; fi
  vw_log "  E · the count face: ${PV[tf]} · markers drawn: ${PV[tmk]}"
  vw_expect_eq "E · the chip turned the scope OFF" "${PV[tfs]}" 0
  vw_require '[[ $every == <-> ]] && (( every > total ))' "takemania's other takes hold more Hyde matches ($every vs $total)" || return
  vw_cap 05-every-take

  # Row F — step until the current match is on a take its block is NOT showing: its fan opens, its card is live.
  local steps=0
  while [[ ${PV[tfo]} != 1 ]] && (( steps < every + 1 )); do
    vw_keys "⏎ (to an off-scope match)" 'key code 36'
    sleep 1.2; vw_probe
    (( steps++ ))
  done
  sleep 2; vw_settle
  vw_expect_eq "F · a step reached a match on a take its block is not showing ($steps steps)" "${PV[tfo]}" 1
  vw_expect_eq "F · the live pane is that take's FAN card (its fan opened on arrival — trole=${PV[trole]:-none})" \
    "${${${PV[trole]:-}:#article}:+fan}" fan
  vw_expect_eq "F · …with the match selected" "${${PV[tsel]:-,}#*,}" 4
  vw_expect_eq "F · …and on screen" "${PV[tvis]:-0}" 1
  vw_cap 06-off-scope-fan-opened

  # Row G — Esc: the bar closes, the keyboard goes to the take, the match still selected.
  vw_keys "Esc (close the bar)" 'key code 53'
  sleep 1.5; vw_settle
  vw_expect_eq "G · Esc closed the bar" "${PV[tf]:-closed}" closed
  vw_expect_eq "G · the take holds the keyboard" "${PV[fr]}" pane
  vw_expect_eq "G · …with the match still selected (sel=${PV[sel]:-none})" "${${PV[sel]:-,}#*,}" 4
  vw_cap 07-esc-take-holds-keyboard

  # Row H — a keystroke EDITS the take (her row-7 report, answered); ⌘Z puts it back.
  local len0=${PV[len]}
  vw_keys "type: X (replaces the selected match)" 'keystroke "X"'
  sleep 1; vw_settle
  local len1=${PV[len]}
  vw_expect_eq "H · the keystroke replaced the 4-letter match (len $len0 → $len1)" "$(( len0 - len1 ))" 3
  vw_keys "⌘Z (text undo)" 'keystroke "z" using command down'
  sleep 1; vw_settle
  vw_expect_eq "H · ⌘Z restored the take" "${PV[len]}" "$len0"
  vw_cap 08-typed-and-undone

  # Row I — ⌘G from the BOARD (the bar closed, the query remembered): the landed take holds the keyboard.
  vw_keys "⌘G (find next, from the take)" 'keystroke "g" using command down'
  sleep 2.5; vw_settle
  vw_expect_eq "I · ⌘G from the board: the landed take holds the keyboard" "${PV[fr]}" pane
  vw_expect_eq "I · …with a 4-letter match selected" "${${PV[sel]:-,}#*,}" 4
  vw_cap 09-cmd-g-from-the-board

  # Tidy: the scope back ON (a session slot — the pass's own launch forgets it anyway), the bar closed.
  vw_keys "⌘F" 'keystroke "f" using command down'; sleep 1; vw_settle
  vw_takes_find_press_chip off || vw_log "  tidy: the chip could not be turned back on (a session slot — the pass's own launch forgets it)"
  sleep 1; vw_keys "Esc" 'key code 53'; sleep 1
}

# The scope chip's accessibility label in the voice on screen (Terminal's chrome lowercases; the chip's
# words are lowercase already, so both voices read the same).
vw_takes_find_chip() { print -r -- "only chosen takes: $1" }

# Press the scope chip whose CURRENT state word is $1: AXPress first, verified by the probe (`tfs`); a press
# the SwiftUI button refuses (measured once, Terminal: `AXUIElementPerformAction` failed, the scope unmoved)
# falls back to a guarded click at the chip's own frame (vis-ax reports it).
vw_takes_find_press_chip() {   # on|off
  local label=$(vw_takes_find_chip $1) want out rc try
  [[ $1 == on ]] && want=0 || want=1
  for try in 1 2 3; do
    vw_act_note "AX press: $label (try $try)"
    vw_step
    out=$($VW_BIN/vis-ax $PID "$label" AXButton press 2>&1); rc=$?
    vw_log "  vis-ax press: rc=$rc out=${out:-none}"
    sleep 1.2; vw_probe
    [[ ${PV[tfs]} == $want ]] && return 0
  done
  out=$($VW_BIN/vis-ax $PID "$label" AXButton 2>&1); rc=$?
  vw_log "  the chip's AXPress did not take (tfs=${PV[tfs]}) — its frame: rc=$rc out=${out:-none}"
  local -a f=(${=out})
  (( ${#f} >= 4 )) || return 1
  vw_click $(( f[1] + f[3] / 2 )) $(( f[2] + f[4] / 2 )) "the scope chip"
  sleep 1.2; vw_probe
  [[ ${PV[tfs]} == $want ]]
}

# --- SELF-TEST: the harness must be able to RED (run with --selftest) -----------------------------------
vw_def selftest-red "whatever is on screen" "none (a quiet second)" \
  "a KNOWINGLY WRONG expectation: the window's top moved 40 pt — must FAIL, be captured, exit non-zero" fail
scn_selftest-red() {
  vw_settle; vw_snap before; vw_cap 01-before
  sleep 1
  vw_settle; vw_cap 02-after
  local w=(${(s:,:)PV[win]}) wb=(${(s:,:)$(vw_get before win)})
  vw_expect_near "SELF-TEST (planted, knowingly wrong): the window's top moved 40 pt" \
    "$w[2]" "$(( wb[2] + 40 ))" 0.5
}

# --- S14: B5's OTHER roads — mid-note on invalidated geometry, the tail on settled geometry (18l-b U-B5) ---
# The fix's walk rows made standing (her B5 gestures beyond the recipe above): after the carve's full
# re-render, a ⏎ at ANOTHER blank line mid-page (the island the exact restore laid out floats on
# estimates too); then ⌘↓ with the region above the tail SETTLED by a small wheel round trip (U0b's
# "settled geometry" row) and ⏎ at the tail. Neither act writes above the first visible line, so it
# must not move. Starts from ⌘↑ so any earlier scenario's resting place cannot put the page in the
# typewriter room (the U3 fixture lesson). Appended LAST: no earlier recipe changes.
vw_def b5-more-roads "A Scandal in Bohemia, Write" \
  "⌘↑ · wheel mid-note · a blank line: ⏎ + ⌫ (the carve) · another blank line: ⏎ (mid-note, invalidated) + ⌫ · ⌘↓ · wheel ±3 · ⏎ at the tail (settled) · ⌫" \
  "(a) neither ⏎ moves the first visible line (offset + y)" pass
scn_b5-more-roads() {
  vw_write_open "A Scandal in Bohemia" || return
  vw_keys "⌘↑ (start at the top)" 'key code 126 using command down'
  vw_settle
  vw_write_scroll 30
  vw_require '[[ -n ${PV[blank]} ]]' "a blank line in the viewport's lower half" || return
  local c=(${(s:,:)PV[colX]}) y=$(( (PV[blankY] + PV[blankY1]) / 2 )) len0=${PV[len]}
  vw_free_x $(( c[1] + 20 )) $(( c[1] + 200 )) $y
  vw_click $FREE_X $y "a blank line mid-page (a block's end)"
  vw_settle
  local blocks0=${PV[blk]#*/}
  vw_keys "⏎ (an empty block below)" 'key code 36'
  vw_settle
  vw_require '[[ ${PV[blk]#*/} == $(( blocks0 + 1 )) ]]' "⏎ at the block's end minted an empty block" || return
  vw_keys "⌫ (the carve → the full re-render)" 'key code 51'
  vw_settle
  vw_require '[[ ${PV[len]} == $len0 && -n ${PV[blank]} ]]' "the carve restored the text and a blank line is on the page" || return
  # Mid-note, on the geometry the full re-render left: another blank line, ⏎.
  y=$(( (PV[blankY] + PV[blankY1]) / 2 ))
  vw_free_x $(( c[1] + 20 )) $(( c[1] + 200 )) $y
  vw_click $FREE_X $y "a blank line mid-page, after the full re-render"
  vw_settle; vw_snap mid; vw_cap 01-mid-before
  vw_keys "⏎ mid-note (invalidated geometry)" 'key code 36'
  vw_settle; vw_cap 02-mid-return
  vw_expect_eq "⏎ mid-note: an empty block below" "${PV[blk]#*/}" $(( blocks0 + 1 ))
  vw_expect_page_still mid "⏎ mid-note on invalidated geometry"
  vw_keys "⌫ (restore)" 'key code 51'
  vw_settle
  vw_require '[[ ${PV[len]} == $len0 ]]' "the mid-note round trip restored the text" || return
  # The tail on SETTLED geometry: ⌘↓, then the wheel up and back down lays out the region above it.
  vw_keys "⌘↓" 'key code 125 using command down'
  vw_settle
  vw_write_scroll -3
  vw_write_scroll 3
  vw_settle; vw_snap tail; vw_cap 03-tail-settled
  vw_require '[[ ${PV[caretEnd]} == 1 ]]' "the caret still at the end after the wheel" || return
  vw_keys "⏎ at the tail (settled geometry)" 'key code 36'
  vw_settle; vw_cap 04-tail-return
  vw_expect_page_still tail "⏎ at the tail on settled geometry"
  vw_keys "⌫ (restore)" 'key code 51'
  vw_settle; vw_cap 05-restored
  vw_expect_eq "restore: text back" "${PV[len]}" $len0
}

# The seeded run's order: the note-open pair FIRST (a fresh launch is every note's first open).
# 18l-b U3 (the B5 fixture): `read-landing` runs AFTER the B5 pair. Seeded before it at 18l U1, its deep
# click left *A Scandal in Bohemia*'s current block at 245, so B5's `vw_write_open` re-opened the note
# there (R-18l-1: a re-open lands the page she left) and its 30-line scroll ended in the typewriter room,
# where no blank line exists — a precondition ERROR in every full Terminal pass since U1 (18l-b U2's
# record: byte-identical on the pre-U2 build). After the B5 pair, every scenario before B5 is exactly the
# U-VIS run order its recipe was MEASURED on (KnownIssues row 88: "the recipe IS the full Study pass"),
# and no act of any scenario changed. `read-landing`'s own faces still mount cold in the pass (its first
# Read open); `takes-landing` stages its own first open by a relaunch, so it is order-independent.
# 18l-b U4: `book-landings` runs LAST (appended — no earlier scenario's recipe changes).
# 18l-b U-B5: `b5-more-roads` appended after it, for the same reason.
# 18l-c U7: `takes-find` appended after it, for the same reason (its fixture is takemania, which no
# earlier scenario touches; its one keystroke is undone).
SCN_ORDER=(note-reopen write-typing write-newline-roundtrip write-divide-merge mode-roundtrip
           index-click readedit-click outline-narrow-restore outline-long-story-settle
           b5-return-after-cmd-down b5-refont read-landing takes-landing book-landings b5-more-roads
           takes-find)
