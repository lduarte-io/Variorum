# Remote Workflow Cheat Sheet — Air ↔ Pro

*For Lillian. Everything from the 2026-10-06 setup day, ordered by how often you'll need it.*

---

## SSH basics

```zsh
ssh home                  # plain terminal ON the Pro (no tmux) — leave with exit or Ctrl-D
ssh home '<command>'      # run one command on the Pro and come straight back
ssh -t home <command>     # same but interactive (what the tmux one-liners use)
scp home:/path/file .     # copy a file Pro → Air (proview wraps this + opens it)
~.                        # typed at the start of a line: force-kill a HUNG ssh
```

`home` = the Pro (`~/.ssh/config` alias, key auth, works from anywhere via Tailscale).

```zsh
# gracefully quit MY Variorum app on the Pro (⌘Q equivalent; real store only, never dev builds)
ssh home 'osascript -e "tell application id \"io.lduarte.Variorum\" to quit"'
```

## Captive portals (hotel/café/office guest Wi-Fi)

1. Tailscale menu → Exit Node → **None** (fail-closed: nothing flows until you do this)
2. `open http://captive.apple.com` — forces the portal login page into your browser
   (plain-HTTP trick; `http://neverssl.com` is the backup)
*[removed for publication]*

---

## Daily start — four Ghostty tabs on the Air, one word each (since 2026-10-06 evening)

```zsh
ws variorum      # Tab 1 — primary; claude lives here, window var-1
ws variorum 2    # Tab 2 — second view, already parked on var-2
ws variorum 3    # Tab 3 — third view, already parked on var-3
ws mobile        # Tab 4 — variorum-mobile (windows mobile-1, mobile-2)
```

`ws` **builds whatever is missing** (the session, the named windows) and then
attaches — so the SAME command works on a fresh day, after a lid-close, and
after a full tmux kill. There is no separate rebuild step anymore, and no
C-b parking: views 2/3 land on their window by themselves. Re-pasting is
always safe.

- Primary (`ws <name>`) = the real session. Views (`ws <name> 2`, `3`, …) =
  grouped viewers that self-destruct when their tab closes; tmux auto-names
  them `variorum-1`, `variorum-2`… — that's normal, they're disposable glass.
- Known workspaces: `variorum` · `mobile` · `stargazing` · `fragments`.
  Anything else defaults to `~/dev/<name>`.
- Sitting at the Pro itself: `~/bin/ws variorum 2` (same script, no ssh).
- The plumbing: `~/bin/ws` on the Pro (the real script), a tiny `ws()` ssh
  wrapper in the Air's `~/.zshrc`. Read the script if you're curious — it's
  the old daily-start/rebuild one-liners made idempotent.

**Keychain caveat (the GUI-born-server rule):** if NO tmux server is alive on
the Pro (first start after a reboot or `kill-server`), running `ws` from the
Air births the server over ssh — shells inside it then can't reach the
Keychain ("User interaction is not allowed"); automation falls back to the
file credentials in `~/.variorum/`. When that matters, start the first
session from a GUI terminal ON the Pro (Screen Sharing counts).

**After closing the lid / losing Wi-Fi:** every tab's ssh dies. Not broken —
re-paste each tab's command (up-arrow ↑ then enter). Nothing was lost.

---

## THE ONE RULE

> **`exit` destroys. Detach only looks away.**

- `C-b d` · closing the lid · losing Wi-Fi · quitting Ghostty → **detach**: everything keeps running on the Pro.
- Typing `exit` in a shell → that shell is **gone for real** (this is also how you *deliberately* close a pane or window — a window dies with its last pane; the session dies with its last window).

---

## Keys you'll use constantly (inside tmux; C-b = Ctrl and b together, release, then the key)

| Keys | What |
|---|---|
| `C-b d` | detach — leave everything running |
| `C-b 0` `C-b 1` `C-b 2` … | jump to window 0 / 1 / 2 (or click names in the bottom bar) |
| `C-b c` | new window (new shell on the Pro) |
| `C-b ,` | rename current window |
| `C-b w` | window picker list |

## Panes (splits inside one window) — for later experimenting

| Keys | What |
|---|---|
| `C-b %` | split side-by-side (new shell on the right) |
| `C-b "` | split top/bottom |
| `C-b z` | zoom pane full-screen / back |
| `C-b` + arrows, or click | move between panes |
| `C-b x` | force-kill a stuck pane (y/n) |
| `C-b &` | force-kill whole window + all its panes (y/n) |
| `C-b q` | flash pane numbers if lost |

---

## Occasional commands

```zsh
ssh home                        # plain remote shell on the Pro, no tmux
ssh home tmux ls                # what sessions are alive on the Pro
tmux neww -c <dir> -n <name>    # (from inside tmux) new window starting in <dir>
ssh home tmux kill-server       # nuclear: kill ALL tmux sessions on the Pro
proview <path-on-pro>           # copy a Pro file (mockup.html etc.) here and open it
pushshot                        # copy newest Air screenshot → Pro, path to clipboard
pushshots [N]                   # copy the N newest (default 2) → Pro, all paths to clipboard
```

**Dropping screenshots into a Pro Claude session** doesn't work directly — the image is on
the Air, the session reads files on the Pro. Instead: take the screenshot(s), run the helper
in a **local Air shell**, then paste (⌘V) into the Claude session. Lands in `~/shots/` on the Pro.
- one shot: `pushshot` (newest), or a specific file e.g. `pushshot ~/Desktop/some-file.png`
- several at once: `pushshots` (2 newest), `pushshots 3` (3 newest), or name them explicitly
  e.g. `pushshots ~/Desktop/a.png ~/Desktop/b.png` —
  all paths land on the clipboard space-separated; one paste attaches them all.

Sitting at the Pro itself: same commands without the `ssh home` / `ssh -t home` wrapper.

## Other machines & roads

```zsh
*[removed for publication]*
```

- **Screen Sharing** (GUI road, for Xcode etc.): the app has two saved Pro entries —
  *[removed for publication]*
  Expect some lag away from home; terminal road is primary for a reason.
*[removed for publication]*
  (Pro is the approved fallback). Keep "Allow local network access" ticked.
  Turn OFF for captive portals (hotel/café login pages). Off = Exit Node → None.
- **Ghostty config changes** don't apply to the running app: press **⌘⇧,** to reload (or restart Ghostty).

---

## What's actually going on (the 30-second version)

```
AIR                                      PRO
Ghostty tab ── ssh ══ tailscale ══ sshd ── tmux ── shells ── claude/builds
(glass: screen+keyboard only)              (the workspace — lives here, never stops)
```

tmux on the Pro holds **sessions** (named workspaces: `variorum`, `mobile`), each
containing **windows** (tabs: `var-1`, `var-2`, `var-3`), optionally split into **panes**.
All work runs on the Pro inside these. Your Ghostty tabs are just panes of glass
pointed at them over ssh — tabs 1–3 are three cameras on the one `variorum`
workspace (each parked on its own window), tab 4 is the camera on `mobile`.
Disconnecting unplugs a camera; the rooms and everything running in them stay.
That's why a dropped connection, closed lid, or dead hotspot never kills a
claude session — and why `exit` is the only word that actually destroys anything.
```

---

*Open this file:*  `cat ~/dev/variorum/notes/remote-workflow-cheatsheet.md`
