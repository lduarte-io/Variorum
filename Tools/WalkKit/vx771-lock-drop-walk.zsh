# Tools/WalkKit/vx771-lock-drop-walk.zsh — the guarded primitives of VX-771's VX-762 verify walk (the lock drop and its
# Activity line, on the DEV store). SOURCED by the walk session, never executed:
#   source Tools/WalkKit/vx771-lock-drop-walk.zsh
# The script of record — the legs, their order, what each must show, the STOP rules — is
# notes/plans/fixes/vx-771-walk-script.md. This file adds only what VX-771's walk needs on top of
# Tools/WalkKit/castle-walk-lib.zsh (VX-502's guarded primitives, sourced below and used as they are):
#   - a SHIM CLIENT driven from the shell: the Debug app's own embedded variorum-mcp, its stdin a FIFO held open by a
#     holder process, its stdout and stderr to files in the gitignored evidence dir (stderr is where VX-762's B2 lines
#     land — part one's generic sentence, or part two's lock-road words);
#   - the setup key taken from the pane's own Copy setup act (the clipboard — her word, walks may use it), kept in a
#     mode-600 file and NEVER printed, logged or captured;
#   - the lock (File ▸ Lock Library Now, by AX menu press) and its evidence.
# The dev store's Castle pair is typed ONLY by ~/.variorum/bin/type-dev-castle-secret (wk_dev_secret) into a PLAIN
# launch (wk_launch_plain); no value is ever printed, logged, captured or committed by this file.

emulate -L zsh 2>/dev/null
WK_REPO=${WK_REPO:-/Users/lillianduarte/dev/variorum-vx-771}
WK_EV=${WK_EV:-$WK_REPO/App/Variorum/DerivedData/vx771-walk-evidence}      # gitignored (DerivedData/)
WK_APP=${WK_APP:-$WK_REPO/App/Variorum/DerivedData/vx771-walk/Build/Products/Debug/Variorum.app}
WK_LEG=${WK_LEG:-W0}
source $WK_REPO/Tools/WalkKit/castle-walk-lib.zsh

VW_SHIM=$WK_APP/Contents/MacOS/variorum-mcp
VW_CLIENT=${VW_CLIENT:-vx771-walk}                 # the walk's own client name — never an existing client's
VW_KEYFILE=$WK_EV/setup-key                        # mode 600; never printed
VW_FIFO=$WK_EV/shim-in.fifo
VW_OUT=$WK_EV/shim-stdout.log
VW_ERR=$WK_EV/shim-stderr.log
VW_DROP_LINE="$VW_CLIENT was disconnected when the library locked or closed"   # MCPPaneCopy.connectionEndPhrase(.libraryClosed)
VW_LOCK_WORDS="Variorum's library locked or closed, so it closed this connection — reconnect with /mcp once it's open again."
VW_GENERIC="Variorum closed the connection — reconnect with /mcp once it's back."
VW_SHIM_PID=${VW_SHIM_PID:-}
VW_HOLD_PID=${VW_HOLD_PID:-}
[[ -f $WK_EV/vw-session.env ]] && source $WK_EV/vw-session.env
vw_save() { mkdir -p $WK_EV; print -r -- "VW_SHIM_PID=${(q)VW_SHIM_PID} VW_HOLD_PID=${(q)VW_HOLD_PID}" > $WK_EV/vw-session.env }

# --- the walk's build (a BUILD only — never a launch; the launch waits for the stage GO) -------------------------------
vw_build() {
  [[ -d $WK_REPO/App/Variorum ]] || { wk_stop "no App/Variorum under $WK_REPO"; return 1 }
  local log=$WK_EV/build-$(date -u +%H%M%S).log; mkdir -p $WK_EV
  ( cd $WK_REPO/App/Variorum && xcodebuild -scheme Variorum -configuration Debug -destination 'platform=macOS' \
      -derivedDataPath $WK_REPO/App/Variorum/DerivedData/vx771-walk build > $log 2>&1 )
  grep -q '\*\* BUILD SUCCEEDED \*\*' $log || { wk_stop "the walk build failed — ${log:t}"; return 1 }
  [[ -x $VW_SHIM ]] || { wk_stop "the build carries no embedded shim at $VW_SHIM"; return 1 }
  wk_log "built the walk app at $(git -C $WK_REPO rev-parse --short HEAD) — ${log:t}; shim embedded"
}

# --- the found posture, before anything moves (the brief's (b): machine state per leg) ---------------------------------
vw_posture() {  # <tag> — the slot's files (names@inodes), instances, the stage, the shim client, the evidence's key file
  local line="POSTURE ${1:-$WK_LEG} $(date -u +%Y-%m-%dT%H:%M:%SZ) | instances: $(wk_instances | tr '\n' ' ')"
  line+=" | slot: $(wk_inodes $WK_SLOT | tr '\n' ' ')| $(wk_hold) | stage: $(wk_stage)"
  line+=" | shim: $( [[ -n $VW_SHIM_PID ]] && kill -0 $VW_SHIM_PID 2>/dev/null && print -r -- "alive pid $VW_SHIM_PID" || print -r -- "none")"
  line+=" | key file: $( [[ -f $VW_KEYFILE ]] && print -r -- "present (mode $(stat -f %Lp $VW_KEYFILE))" || print -r -- absent)"
  mkdir -p $WK_EV; print -r -- $line | tee -a $WK_EV/state.log
}

# --- reading the screen (no secrets can be on these surfaces; the words guard still runs before every capture) ---------
vw_on_screen() { $WK_BIN/vis-ax $WK_PID "$1" ${2:--} >/dev/null 2>&1 }           # exact label (case-insensitive)
vw_on_screen_prefix() { VIS_AX_PREFIX=1 $WK_BIN/vis-ax $WK_PID "$1" ${2:--} >/dev/null 2>&1 }
vw_texts() {  # every static text of the FRONT window of our pid (System Events), one per line, into the evidence log
  wk_author || return 1; wk_activate
  local g; g=$($WK_BIN/words-guard $WK_PID 2>/dev/null) || { wk_log "texts WITHHELD — $g"; return 0 }
  osascript -e "tell application \"System Events\" to tell (first application process whose unix id is $WK_PID) to get value of every static text of entire contents of window 1" \
    2>/dev/null | tr ',' '\n' | sed 's/^ //' | tee -a $WK_EV/texts-$WK_LEG.log
}
vw_menu() {  # <menu> <item> — a menu bar press addressed to our pid (System Events, through keys.sh's guards)
  wk_keys "tell (first application process whose unix id is $WK_PID) to click menu item \"$2\" of menu 1 of menu bar item \"$1\" of menu bar 1"
  wk_log "menu $1 ▸ $2"
}

# --- the setup key, from the pane's own Copy setup act ----------------------------------------------------------------
vw_take_key() {  # after the driver pressed the Connect tab's copy icon with "Any MCP client" chosen: the key off the clipboard
  local text key
  text=$(pbpaste)
  # An "Any MCP client" copy carries an UNTAGGED key (MCPSetupKeyRule.prefix — vmk1_ + 43 base64url characters); a
  # client tab's copy carries vmk2_<name>_… and would bind that client's name — refused here.
  if print -r -- $text | grep -q 'vmk2_'; then unset text; wk_stop "that copy is a client tab's (tagged) — choose Any MCP client"; return 1; fi
  key=$(print -r -- $text | grep -oE 'vmk1_[A-Za-z0-9_-]{43}' | head -1)
  unset text
  [[ -n $key ]] || { wk_stop "the clipboard holds no untagged setup key — press the setup's copy icon first"; return 1 }
  ( umask 077; print -rn -- $key > $VW_KEYFILE ); unset key
  print -n "" | pbcopy   # the clipboard keeps no key past this step
  [[ $(stat -f %Lp $VW_KEYFILE) == 600 ]] || { wk_stop "the key file is not mode 600"; return 1 }
  wk_log "setup key taken from the pane's Copy setup act into a mode-600 file (never printed); clipboard cleared"
}

# --- the shim client ------------------------------------------------------------------------------------------------
vw_client_start() {  # the Debug app's own shim, keyed, named $VW_CLIENT; stdout/stderr to the evidence dir
  [[ -x $VW_SHIM && -f $VW_KEYFILE ]] || { wk_stop "no shim or no key file"; return 1 }
  [[ -z $VW_SHIM_PID ]] || ! kill -0 $VW_SHIM_PID 2>/dev/null || { wk_stop "a walk shim is already running (pid $VW_SHIM_PID)"; return 1 }
  rm -f $VW_FIFO; mkfifo -m 600 $VW_FIFO || return 1
  : > $VW_OUT; : > $VW_ERR
  VARIORUM_MCP_KEY="$(<$VW_KEYFILE)" nohup $VW_SHIM < $VW_FIFO > $VW_OUT 2> $VW_ERR &
  VW_SHIM_PID=$!
  nohup sleep 86400 > $VW_FIFO &
  VW_HOLD_PID=$!
  vw_save
  vw_send '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"'$VW_CLIENT'","version":"1"}}}'
  local i; for i in {1..20}; do grep -q '"id":1' $VW_OUT && break; sleep 0.5; done
  grep -q '"id":1' $VW_OUT || { wk_stop "the shim's initialize got no answer (stderr: $(tail -1 $VW_ERR))"; return 1 }
  vw_send '{"jsonrpc":"2.0","method":"notifications/initialized"}'
  wk_log "shim client '$VW_CLIENT' up — pid $VW_SHIM_PID (holder $VW_HOLD_PID); initialize answered"
}
vw_send() { print -r -- "$1" >> $VW_FIFO }
vw_call() {  # <id> <tool> [<arguments json>] — a tools/call; prints the answer line (dev-store content only)
  vw_send '{"jsonrpc":"2.0","id":'$1',"method":"tools/call","params":{"name":"'$2'","arguments":'${3:-'{}'}'}}'
  local i; for i in {1..20}; do grep -q "\"id\":$1[,}]" $VW_OUT && break; sleep 0.5; done
  grep "\"id\":$1[,}]" $VW_OUT | tail -1
}
vw_list_tools() {  # <id> — how many tools the client is listed now
  vw_send '{"jsonrpc":"2.0","id":'$1',"method":"tools/list"}'
  local i; for i in {1..20}; do grep -q "\"id\":$1[,}]" $VW_OUT && break; sleep 0.5; done
  grep "\"id\":$1[,}]" $VW_OUT | tail -1 | grep -o '"name":"[a-z_]*"' | wc -l | tr -d ' '
}
vw_client_alive() { [[ -n $VW_SHIM_PID ]] && kill -0 $VW_SHIM_PID 2>/dev/null }
vw_client_stderr() { cat $VW_ERR }                  # B2's line(s) — the app's words or the generic sentence
vw_client_stop() {  # the holder ends → the shim's stdin ends → it half-closes and exits (the client's own close)
  [[ -n $VW_HOLD_PID ]] && kill $VW_HOLD_PID 2>/dev/null
  local i; for i in {1..20}; do vw_client_alive || break; sleep 0.5; done
  vw_client_alive && { kill -TERM $VW_SHIM_PID 2>/dev/null; wk_log "the shim needed a TERM (pid $VW_SHIM_PID)" }
  rm -f $VW_FIFO; VW_SHIM_PID=; VW_HOLD_PID=; vw_save
  wk_log "shim client stopped"
}
vw_forget_key() { [[ -f $VW_KEYFILE ]] && rm -P $VW_KEYFILE 2>/dev/null; rm -f $VW_KEYFILE; wk_log "the key file removed" }

# --- the drop: did the lock end the client's connection, and what did each side say? -----------------------------------
vw_drop_seen() {  # after the lock: the shim exited by itself (the app's end), its stderr says why, Activity reads later
  local i; for i in {1..30}; do vw_client_alive || break; sleep 0.5; done
  if vw_client_alive; then wk_stop "the shim is still connected after the lock — the drop did not happen"; return 1; fi
  wk_log "the shim exited by itself after the lock (the app ended the connection)"
  local said; said=$(vw_client_stderr)
  if [[ $said == "$VW_LOCK_WORDS" ]]; then wk_log "shim stderr: the lock road's words (B2 part two) — exact"
  elif [[ $said == "$VW_GENERIC" ]]; then wk_log "shim stderr: part one's generic sentence (no close line arrived)"
  else wk_log "shim stderr (verbatim, $(print -rn -- $said | wc -l | tr -d ' ') lines): $said"; fi
  if LC_ALL=C grep -q $'\x1e' $VW_OUT; then wk_stop "a close line reached the client's stdout"; return 1; fi
  wk_log "no 0x1E byte on the client's stdout"
  VW_SHIM_PID=; [[ -n $VW_HOLD_PID ]] && kill $VW_HOLD_PID 2>/dev/null; VW_HOLD_PID=; vw_save; rm -f $VW_FIFO
}
