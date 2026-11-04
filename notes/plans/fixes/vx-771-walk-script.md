# VX-771 — the VX-762 verify walk: the script of record

**What it verifies (R-771-C):** on a build ≥ 0.10.6, locking the library still drops a connected MCP client, the server
starts again at the unlock while the client stays dropped until it reconnects, and Settings ▸ MCP ▸ Activity says the
lock road's ruled line — `‹client› was disconnected when the library locked or closed` (`MCPPaneCopy.connectionEndPhrase`,
P-VX394-1). On a build carrying this run's B2 (VX-762, P-771-3, A-771-3) it also reads what the CLIENT was told: the shim's
one stderr line — the lock road's words, "Variorum's library locked or closed, so it closed this connection — reconnect
with /mcp once it's open again." This is evidence of shipped machinery, not a trace (VX-394's trace is done).

**Status: PENDING — Road A** (the stage coordinator's re-sequencing, 2026-11-04): the shared dev store is very likely on
v1_36 (VX-500's test hosts migrated it), so a build of this branch before `main` carries VX-500 would refuse it
(`newerSchema`). The walk runs only when ALL of these hold:

1. VX-500 has merged to `main` and `main` is merged into `vx-771-mcp-agent-ergonomics` (the migration suites re-run green
   after the merge-in, the coordinator's merge rule).
2. The orchestrator has relayed **GO with the exact claim line** from the stage coordinator. Before it: no launch, no GUI,
   no store touched. The driver messages the orchestrator **"READY for vx771-walk"** when the build is ready that minute.
3. Her `/Applications/Variorum.app` is NOT running and no one is at the machine — `Tools/WalkKit/guard.sh --author`
   passes (it refuses otherwise, and a refusal is never retried around).

**The hard rules (the brief's, verbatim in substance):** the Debug build `io.lduarte.Variorum.debug` only, never
`/Applications`; the dev store's Castle pair from `~/.variorum/dev-castle.env` typed ONLY by
`~/.variorum/bin/type-dev-castle-secret` (via `wk_dev_secret`) — never invented, never written into a commit, record, log
or screenshot; the dev store's content is the agents' to manage; the app never signs into her account (a plain launch —
no `VARIORUM_*` key); clipboard use is fine; captures and logs go to the gitignored
`App/Variorum/DerivedData/vx771-walk-evidence/`; the words guard runs before every capture (`wk_capture`). Anything only
the author can do → STOP, record, report.

**The tools:** `source Tools/WalkKit/vx771-lock-drop-walk.zsh` (it sources `Tools/WalkKit/castle-walk-lib.zsh`, VX-502's
guarded primitives: `wk_setup`, `wk_zero`, `wk_launch_plain`, `wk_press`, `wk_focus`, `wk_dev_secret`, `wk_enter`,
`wk_capture`, `wk_quit`, `wk_state`). Each Bash call is a fresh shell: re-source the file every call; the session's facts
(pids, the leg) persist in the evidence dir. Labels the script cannot know in advance (the What's New button, the lock
screen's passphrase field, the setup's copy icon) are found on screen by `vis-ax` — `vw_on_screen` / `vw_texts` — never by
guessed coordinates (the WalkKit facts).

**Recording:** after EVERY leg, the driver copies that leg's `STATE` / `POSTURE` lines (`$WK_EV/state.log`) and its
`walk.log` lines into the BATCH 4 RECORD's walk section of `notes/plans/fixes/vx-771-mcp-agent-ergonomics.md`, commits,
and pushes (one push attempt). A stop or an interruption mid-walk is followed by a VERIFY-NOT-TRUST state check
(`vw_posture`, `wk_instances`, is a lock screen up? is the shim alive?) before anything resumes.

## The legs

**W0 — setup and the found posture (no app running).**
`wk_leg W0; wk_setup; vw_build` (a build at the post-merge head; a BUILD only) `; wk_zero; vw_posture W0-found; wk_state W0`.
Record: the head the walk app was built from, zero instances, the slot's files, the stage line.

**W1 — launch, and the library as found.**
`wk_leg W1; wk_launch_plain`. If What's New shows, dismiss it by its button (`vw_texts`, then `wk_press "<its label>"`).
Record the FOUND POSTURE: the library opened on its lock screen (Castle, locked at launch) or straight to the Bookcase.
If locked: find the passphrase field (`vw_texts`), then `wk_focus "<field label>"; wk_dev_secret passphrase; wk_enter`;
wait for the main window; `wk_capture W1-open`. A refused passphrase is a STOP (never a second guess at a value).

**W2 — the MCP switch.**
⌘, (`wk_keys 'keystroke "," using command down'`) → the MCP pane. Read "Enable the MCP server" (`MCPPaneCopy.enableTitle`)
— record FOUND ON or OFF; if OFF, turn it ON (`wk_press "Enable the MCP server"`) and note it for W8's restore. The
status line must read running (`vw_texts`). `wk_capture W2-mcp`.

**W3 — the walk's client key, through the pane's own road.**
The Connect tab (`MCPPaneCopy.connectTab`, "Connect"); choose **Any MCP client** in the setup's header (`MCPSetupClient
.anyClient` — an UNTAGGED key, so the client name is the walk's own, never an existing client's binding); press the setup
code block's copy icon (the one declared copy act, VX-205); then `vw_take_key` (the key into a mode-600 file, never
printed; the clipboard cleared). Record: **"a setup key minted through the pane's own Copy setup road (Any MCP client)
for the walk's client `vx771-walk`"**.

**W4 — the client connects and is served.**
`vw_client_start` (the Debug app's own embedded `variorum-mcp`, keyed; stdout/stderr to the evidence dir). In the pane:
the connection request for `vx771-walk` (Waiting) → approve it (approve ALONE — W-UX-2: zero reach); its Clients row ▸
**Share a place…** (`MCPPaneCopy.sharePlaceVerb`) → the grant sheet: the **Home** wing · **read** · **always** → confirm.
Then `vw_list_tools 2` (> 0 tools) and `vw_call 3 list_wings` (answers Home). `wk_capture W4-served` on the Shared with AI
tab. Record the tool count and that `list_wings` answered.

**W5 — LOCK.**
`wk_leg W5; vw_menu File "Lock Library Now"` (⌃⌘L's menu item — `EditorCommands.lockLibraryNow`). The lock screen shows
(`wk_capture W5-locked`, the words guard first). `vw_drop_seen`: the shim must exit BY ITSELF (the app ended the
connection), and its stderr is recorded verbatim — on this branch's build, the lock road's words (`VW_LOCK_WORDS`);
part one's generic sentence means no close line arrived (record it — a finding, not a stop). No 0x1E byte may reach the
client's stdout. Record: the drop (yes/no), the stderr line verbatim.

**W6 — UNLOCK; the server restarts, the client stays dropped.**
`wk_leg W6`; the passphrase field → `wk_focus "<field label>"; wk_dev_secret passphrase; wk_enter`; the main window back.
Settings ▸ MCP: the status reads running again; the Clients row for `vx771-walk` reads "last seen …" (never "connected
now" — no reconnect was made; the shim process is gone). `wk_capture W6-unlocked`.

**W7 — READ ACTIVITY.**
The Activity tab (`MCPPaneCopy.activitySection`). `vw_on_screen "vx771-walk was disconnected when the library locked or
closed" AXStaticText` must answer (exit 0 — the EXACT words, case-insensitive match); `vw_texts` records the tab's lines;
`wk_capture W7-activity`. Record the drop line's EXACT words and the verdict: does the ≥ 0.10.6 line say the lock road's
ruled words?

**W8 — CLEANUP (nothing of the walk outlives it) and the restored posture.**
The Clients row ▸ **Deny…** → confirm **Deny** (`MCPPaneCopy.denyClientConfirm` — Deny revokes every grant the client
holds and RELEASES its binding, MCPSpec's A-4); verify Shared with AI lists no `vx771-walk` row
(`vw_on_screen_prefix "vx771-walk"` on that tab answers nothing). Restore the switch to W2's FOUND value. `vw_forget_key`.
Close Settings. `wk_quit` (identity-addressed; its outcome read) — then, as ITS OWN step, `wk_zero` and
`pgrep -fl 'Variorum.app/Contents/MacOS'` (only the walk's own instance was ever quit — her app was never running, the
guard's premise). `vw_posture W8-restored; wk_state W8`. The library at rest is as found (the same slot files' names,
unlocked at the walk's end and quit; its Castle posture untouched — nothing here moves it into or out of Castle).

**W9 — RELEASE.** Message the orchestrator: **"RELEASE vx771-walk — found: ‹W1/W2 posture›; restored: ‹W8 posture›;
client vx771-walk denied (grants revoked, binding released); Activity: ‘‹exact line›’; shim stderr: ‘‹exact line›’"**,
and flip the record's LIVE STATUS row 6 with the leg log's evidence.
