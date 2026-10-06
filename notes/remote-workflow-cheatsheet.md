# Remote Workflow Cheat Sheet — Air ↔ Pro

*For Lillian. Everything from the 2026-10-06 setup day, ordered by how often you'll need it.*

---

## Daily start — four Ghostty tabs on the Air, paste one each

```zsh
# Tab 1 — variorum, primary (claude lives here)
ssh -t home tmux new -A -s variorum

# Tab 2 — variorum, second view → then press  C-b 1  to park it on var-2
ssh -t home 'tmux new-session -t variorum \; set destroy-unattached on'

# Tab 3 — variorum, third view → then press  C-b 2  to park it on var-3
ssh -t home 'tmux new-session -t variorum \; set destroy-unattached on'

# Tab 4 — variorum-mobile
ssh -t home tmux new -A -s mobile
```

## More workspaces — same pattern (primary attach + extra views)

Every session has a second window pre-made; park an extra view on it with `C-b 1`.

```zsh
# variorum-mobile, extra view → C-b 1 parks on mobile-2
ssh -t home 'tmux new-session -t mobile \; set destroy-unattached on'

# stargazing-tech (windows star-1, star-2)
ssh -t home tmux new -A -s stargazing
ssh -t home 'tmux new-session -t stargazing \; set destroy-unattached on'   # extra view → C-b 1

# fragments (windows frag-1, frag-2)
ssh -t home tmux new -A -s fragments
ssh -t home 'tmux new-session -t fragments \; set destroy-unattached on'   # extra view → C-b 1
```

The general pattern, for any future workspace:
`ssh -t home tmux new -A -s <name> -c <dir>` once, then the grouped-view one-liner with `-t <name>` for each extra tab.

**After closing the lid / losing Wi-Fi:** every tab's ssh dies. Not broken —
re-paste each tab's command (up-arrow ↑ then enter), re-park tabs 2–3. Nothing was lost.

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
```

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
