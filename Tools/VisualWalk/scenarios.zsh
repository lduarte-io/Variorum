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
typeset -g KI_B5='KI row 88 (B5: ⏎ after ⌘↓ on invalidated geometry; owner 18l)'
typeset -g KI_S3='KI "read tier re-wraps under the pointer" (18l U0 S3; owner the Design & UI review)'

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
  vw_expect_eq "first open: caret at the start" "${PV[sel]}" "0,0"
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
                        # line, then the block ABOVE it on its FIRST line (above: the first swap's reflow
                        # cannot move it), asserting (c) each time.
  local key=$1 label=$2
  vw_probe rt
  local band_top=$(( WIN_Y + $3 )) band_bot=$(( WIN_Y + WIN_H - 20 ))
  local -a fit; local r
  for r in ${(s:;:)PV[$key]}; do
    local q=(${(s:,:)r})
    (( q[2] >= band_top && q[2] + q[4] <= band_bot )) && fit+=($r)
  done
  vw_require '(( ${#fit} >= 2 ))' "two read-tier blocks fully on screen ($key)" || return
  # The lower target is the lowest block of FIVE or more lines (≥ 100 pt): tall enough that the
  # known read-tier re-wrap (S3: the live pane drops the tier's 4-pt line spacing, so line k rises
  # 4k pt) must show on its last line — a standing measurement of S3, not a coin toss on block size.
  local low= up= i min
  for min in 100 50; do
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
  # 1. the LOWER block's LAST line — her trigger: the line right above the blank separator.
  local y=$(( L[2] + L[4] - 8 )) x
  vw_free_x $L[1] $(( L[1] + L[3] * 0.5 )) $y; x=$FREE_X
  vw_click $x $y "$label: the last line of a block"
  vw_settle; vw_cap 01-last-line
  vw_expect_eq "$label last line: a pane went live under the caret" "${PV[fr]}" pane
  vw_expect_eq "$label last line: the caret is NOT on the empty line under the text" \
    "$([[ ${PV[nl]} == 1 && ${PV[caretEnd]} == 1 ]] && print on-the-blank-line || print on-text)" on-text
  # (Not "the block's last live line": the live pane shows the markdown markers the tier hides, so
  # it can wrap the block one line longer — S3 again; the character is the pinned half, in-suite.)
  vw_expect_eq "$label last line: the caret is on a TEXT line (not the empty one)" \
    "$(( PV[caretLine] < PV[caretTextLines] ))" 1
  vw_expect_between "$label last line: the clicked line stays under the pointer (click y in its box)" \
    $y $(( PV[caretY0] - 1 )) $(( PV[caretY1] + 1 )) "$KI_S3"
  # 2. the block ABOVE, on its FIRST line.
  y=$(( U[2] + 8 ))
  vw_free_x $U[1] $(( U[1] + U[3] * 0.5 )) $y; x=$FREE_X
  vw_click $x $y "$label: the first line of the block above"
  vw_settle; vw_cap 02-first-line
  vw_expect_eq "$label first line: a pane went live" "${PV[fr]}" pane
  vw_expect_eq "$label first line: the caret is on the first line" "${PV[caretLine]}" 0
  vw_expect_eq "$label first line: not at the block's end" "${PV[caretEnd]}" 0
  vw_expect_between "$label first line: y inside the caret's line box" $y \
    $(( PV[caretY0] - 1 )) $(( PV[caretY1] + 1 ))
  vw_expect_near "$label first line: caret x at the click" "${PV[caretX]}" $x 12
}

vw_def index-click "The Adventures of Sherlock Holmes ▸ Index, scrolled into A Scandal in Bohemia" \
  "click a block's LAST line (above its blank separator) · click the block above on its FIRST line" \
  "(c) a pane goes live with the caret ON the clicked line — never the blank line; first-line caret under the pointer" \
  "the last line's post-swap y: $KI_S3"
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
vw_def readedit-click "A Scandal in Bohemia ▸ Read ▸ edit" \
  "click a block's LAST line · click the block above on its FIRST line" \
  "(c) as the Index" "the last line's post-swap y: $KI_S3"
scn_readedit-click() {
  vw_open_note "A Scandal in Bohemia"
  vw_keys "⌘3 (Read)" 'keystroke "3" using command down'
  vw_settle rt
  if [[ ${PV[face]} != edit ]]; then vw_ax_press edit AXButton; vw_settle rt; fi
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

# --- S9: B5 — ⏎ right after a ⌘↓ landing on invalidated geometry (KnownIssues row 88) ---------------------
vw_def b5-return-after-cmd-down "A Scandal in Bohemia, Write" \
  "a blank line mid-page · ⏎ + ⌫ (the carve's full re-render invalidates layout) · ⌘↓ · ⏎ at the tail · ⌫" \
  "(a) the ⏎ at the tail must not move the page (the lines above the caret)" \
  "$KI_B5 — HISTORY-DEPENDENT: U0b measured +109/+166 on 998f7d7d; U-VIS reproduced it in the FULL Study pass on both full runs, identical numbers (45591 @ 298 → 45509 @ 302: the lines above the caret slid ~30 pt down under an unmoved clip — U0b's hypothesis, measured); not in Terminal, not from a fresh launch, not after outline or Read ▸ edit alone. XFAIL when it moves, XPASS when it does not"
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
  vw_expect_page_still tail "⏎ at the tail" "$KI_B5"
  vw_keys "⌫ (restore)" 'key code 51'
  vw_settle; vw_cap 03-restored
  vw_expect_eq "restore: text back" "${PV[len]}" $len0
}

# --- S10: B5's re-font road — ⏎ after ⌘↓ when a whole-document RE-FONT invalidated the layout ----------
vw_def b5-refont "A Scandal in Bohemia, Write" \
  "a voice switch (the whole-document re-font) · ⌘↓ · ⏎ at the tail · ⌫ · the voice switched back" \
  "(a) the ⏎ at the tail must not move the page" \
  "$KI_B5's re-font road (U0b named it) — not reproduced at U-VIS's first runs; XFAIL when it moves"
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
  vw_expect_page_still tail "⏎ at the tail (after a re-font)" "$KI_B5"
  vw_keys "⌫ (restore)" 'key code 51'
  vw_settle
  vw_expect_eq "restore: text back" "${PV[len]}" $len0
  vw_set_voice $here
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

# The seeded run's order: the note-open pair FIRST (a fresh launch is every note's first open).
SCN_ORDER=(note-reopen write-typing write-newline-roundtrip write-divide-merge mode-roundtrip
           index-click readedit-click outline-narrow-restore b5-return-after-cmd-down b5-refont)
