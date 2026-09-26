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
                        # line, then the block ABOVE it on its FIRST line (above: the first swap's reflow
                        # cannot move it), asserting (c) each time.
  local key=$1 label=$2
  vw_probe rt
  local band_top=$(( WIN_Y + $3 )) band_bot=$(( WIN_Y + WIN_H - 20 ))
  # The oracles keep a row's LAST frame after the lazy column lets the row go (C4 releases a surface's
  # rows only when the surface leaves), so a note whose page scrolled after its first layout carries
  # STALE frames standing over live ones (found at round 1's discriminating run: a 360-pt ghost of a
  # de-realized paragraph over a run of one-line rows). Rows never overlap, so any frame that overlaps
  # another is suspect — both are dropped, and what remains is unambiguous.
  local -a all fit; local r o
  all=(${(s:;:)PV[$key]})
  for r in $all; do
    local q=(${(s:,:)r}) clash=0
    for o in $all; do
      [[ $o == $r ]] && continue
      local p=(${(s:,:)o})
      (( q[2] < p[2] + p[4] && p[2] < q[2] + q[4] )) && { clash=1; break }
    done
    (( ! clash && q[2] >= band_top && q[2] + q[4] <= band_bot )) && fit+=($r)
  done
  vw_require '(( ${#fit} >= 2 ))' "two read-tier blocks fully on screen ($key)" || return
  # The lower target is the lowest block of EIGHT or more lines (≥ 200 pt; else 5+, else 3+): tall
  # enough that the known read-tier re-wrap (S3: the live pane drops the tier's 4-pt line spacing, so
  # line k rises ~4k pt) shows on its last line in both voices — a standing measurement of S3, not a
  # coin toss on block size (round 1: a 5-line block's shift stayed inside its line in Study).
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
  # 1. the LOWER block's LAST line — her trigger: the line right above the blank separator.
  local y=$(( L[2] + L[4] - 8 )) x
  vw_free_x $L[1] $(( L[1] + L[3] * 0.5 )) $y; x=$FREE_X
  vw_click $x $y "$label: the last line of a block"
  vw_settle; vw_cap 01-last-line
  # The pane that went live must stand where the frame said the block was (the tiers share their first
  # line's top — 13u2 B): a frame that was a stale ghost is the HARNESS's error, never the product's.
  vw_require '(( abs(PV[topY] - L[2]) <= 12 ))' "the clicked frame was the block's live place (pane top ${PV[topY]} vs frame ${L[2]})" || return
  vw_assert_last_line_click "$label" $y
  # 2. the block ABOVE, on its FIRST line.
  y=$(( U[2] + 8 ))
  vw_free_x $U[1] $(( U[1] + U[3] * 0.5 )) $y; x=$FREE_X
  vw_click $x $y "$label: the first line of the block above"
  vw_settle; vw_cap 02-first-line
  vw_require '(( abs(PV[topY] - U[2]) <= 12 ))' "the clicked frame was the block's live place (pane top ${PV[topY]} vs frame ${U[2]})" || return
  vw_assert_first_line_click "$label" $x $y
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
  # the block one line longer (S3). The pre-fix Read ▸ edit landing (line 0) reds here.
  local last=$(( PV[caretTextLines] - 1 ))
  # ...in the block's LAST paragraph (round 2, NIT-R2-5): the line count is paragraph-relative, so a
  # multi-paragraph block's first paragraph could satisfy it; the pane holds one block.
  vw_expect_eq "$label last line: the caret in the block's LAST paragraph" "${PV[caretFragLast]}" 1
  vw_expect_between "$label last line: the caret on the block's last text line (or the one S3's wrap adds)" \
    "${PV[caretLine]}" $(( last - 1 )) $last
  vw_expect_between "$label last line: the clicked line stays under the pointer (click y in its box)" \
    $y $(( PV[caretY0] - 1 )) $(( PV[caretY1] + 1 )) "$KI_S3"
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
vw_def readedit-click "The Red-Headed League ▸ Read ▸ edit (its first open in the pass: no landing scroll, so no stale rows)" \
  "click a block's LAST line · click the block above on its FIRST line" \
  "(c) as the Index" "the last line's post-swap y: $KI_S3"
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
  "$KI_B5 — HISTORY-DEPENDENT: U0b measured +109/+166 on 998f7d7d; U-VIS reproduced it in the FULL Study pass on both full runs, identical numbers (45591 @ 298 → 45509 @ 302: the lines above the caret slid ~30 pt down under an unmoved clip — U0b's hypothesis, measured); not in Terminal, not from a fresh launch, not after outline or Read ▸ edit alone. XFAIL when it moves, XPASS when it does not (Study; plain in Terminal)"
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
  # KNOWN only where it reproduced — the Study pass (round 1, MINOR-2); plain in Terminal, so a move
  # there reds and a standing non-reproduction stops producing an XPASS every run.
  vw_expect_page_still tail "⏎ at the tail" "$([[ $VOICE == study ]] && print -r -- $KI_B5)"
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
           index-click readedit-click outline-narrow-restore outline-long-story-settle
           b5-return-after-cmd-down b5-refont)
