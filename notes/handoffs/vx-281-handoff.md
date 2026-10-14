# VX-281 handoff — the MCP settings pane in tabs, and the shared icon everywhere (2026-10-14)

**Run:** VX-281 "Run: MCP settings pane & shared icon" · PR #159, merged to `main` as merge commit `0f5efe1c` ·
the record `notes/plans/fixes/vx-281-mcp-settings-pane-shared-icon.md` (rulings, both unit records, the three-round
ladder) · built overnight 2026-10-13/14 under your mandate: *"continue on through the night ending in a merge to
main … Rule provisionally in my absence and leave me a handoff with any needed information to note down."*

## Your checklist

1. **Ratify or reverse the nine provisional calls — QUESTIONS #219.** Each was built as stated, with a line to
   reverse it:
   - **Connection requests sit above the tabs, beside Waiting** (not inside Clients). Your ruling placed Waiting,
     not the requests.
   - **"Remembered per session" means this app run.** Your tab pick survives switching panes, closing Settings and a
     lock; quitting clears it. Never stored or synced.
   - **The tab row scrolls with the pane** (every other Settings pane's idiom), rather than a pinned tab bar.
   - **A wing's ▾ menu row shows one mark, and a waiting ask outranks the shared mark.** The full icon and its
     popover live on the ⌘L switcher's rows.
   - **The wing name in the masthead wears no shared icon.**
   - **Rows show reach even while the MCP server is off**, the same rule the Bookcase already follows.
   - **A wing wears the icon only under a wing grant or the open book**, never because of note or book grants
     inside it.
   - **⌘L's Change… opens the grant sheet on top of the switcher.**
   - **A Settings search for "client" or "clients" opens the Clients tab** (a new search entry). Every setup word
     (setup, connect, codex, json, stdio, claude) opens Connect.
2. **Your wording pass, VX-234, can take the MCP pane now.** The run's wording list is posted on VX-234 (U1-1…U1-11,
   R1-4w, R1-8w, R2-3w): every new one-line summary, the two new search entries' blurbs, "Connect" as the first
   tab's name, and two questions only you can answer — whether the edit rung's (i) should read as a capitalized
   sentence (it shows the line's lowercase fragment), and whether the next step should show twice after a copy (the
   line under the code block and the "Copied. …" receipt say the same sentence).
3. **Taste notes from the walks, no action needed unless you want one:** the shared icon reads large beside the
   Book Panel's small type; the Pool's tucked run stays open across a wing switch.
4. **Seeing it:** this merge did not refresh `/Applications` (your rule: only the night's last merge does, and the
   coordinator named VX-282/VX-246 after us). Once the night's refresh lands: open Settings ▸ MCP (it opens on
   Clients when a client is approved, Connect otherwise); press the copy icon on Connect's code block and paste; open
   the Library, Pool, a book's Book Panel and ⌘L with a client that reaches something — the shared icon sits where
   the waiting-ask icon would, with its hover and popover (Change… / Revoke).

## What shipped

- **VX-199 — Settings ▸ MCP in tabs (your R-VX184-6 pick).** The switch and status on top; Waiting and connection
  requests above the tabs; Connect · Clients · Shared with AI · Activity; opens on Connect until a client is
  approved, then on Clients, and remembers your pick for the app run. Every explainer is one line, with its whole
  text behind an (i) — a new shared component, `Core/Views/ExplainerLine.swift`, for the settings work to reuse. The
  grant sheet's edit-rung line is one line with its (i), and says the as-built reach (the "commit before and after
  every change" claim is gone).
- **VX-205 — the code block.** The setup command sits in a code block with the client chosen in its header and the
  copy icon in the upper right. The icon is the same single copy act as before (its old button label is now the
  icon's tooltip and VoiceOver name).
- **VX-232 — fixed, not just mooted.** The setup choice now lives beside its "Copied." receipt, so a voice flip (or a
  remount) can no longer show one client under another client's receipt. Its test failed on the old pane.
- **VX-245 — the two MCP lint sites** (`3d00a166`, posted on VX-245). The other six are VX-283's.
- **VX-268 — the shared icon everywhere the waiting-ask icon is.** Library note, book and gathering rows (List,
  Cards, Timeline, the search answer sheet), Pool rows, Book Panel rows, and the ⌘L switcher's wing rows (the ▾ menu
  shows a mark only). Not Blocks-scope rows (your call). With the open book on, every row it reaches wears it,
  matching the Bookcase (your call). Reach is read with the same rules as the note's indicator and the Bookcase, only
  for the rows on screen, and nothing is read while no client is approved.

## How it was checked

- **Two units, each with a Mac test batch and a walk in both voices.** U1: 250 tests / 31 suites; the walk covered
  every tab, every (i), the copy-and-paste, Waiting, Esc = Don't allow, Change…/Revoke, the VX-232 voice flip and the
  fresh pane. U2: 812 tests / 149 suites; the walk covered every host, the rows that must stay bare, Change… and
  Revoke from the popover, the open book, and no icon once no client is approved. Both walks restored the dev store
  byte-for-byte (Standard, unlocked), with prefs and clipboard put back.
- **The ladder, closed at its three-round cap:** Opus round 1 found 1 blocker (the Timeline checked reach for every
  loaded row on every autosave — fixed so it covers only rows near the screen), 5 minor and 3 nits, all fixed or
  dismissed with proof; Opus round 2 found 1 minor (the Library kept a hidden reach check in Timeline mode — fixed)
  and 4 nits; your end-of-run Fable review found 2 nits — one fixed (overlapping copy ✓ flashes) and checked by me
  line by line, one withdrawn by Fable as unfounded on the implementer's trace. Every bug-class fix carries a test
  that failed on the old code.
- **The merge-moment run:** the whole Mac test target on the merged tip — 4,590 tests in 748 suites, 10 issues, 5 of them tests' own declared ones. The three reds are all standing ones from other tickets (VX-115; VX-283's six lint sites; VX-167's redo test under parallel runs). No new red. Headless: MCP 212/41 · core 2,790/321 · workbook 40/6.

## For the other runs

- **VX-246 (session vx-246):** its docs unit, VX-197, can start now — the field guide still says the shared icon
  appears only on the Bookcase, and lesson 2 says "press Copy setup command" (now an icon). VX-258's face builds on
  the tabbed pane: the re-bind ask goes in Waiting above the tabs; `MCPDoor.setupClient` / `chooseSetupClient` hold
  the chosen client; `clientBoundary` and `keyLine` now render as one-line summaries, so a changed sentence brings
  its summary along.
- **VX-283:** `TimelineView.swift`, `LibraryCatalogPaging.swift`, `LibraryCatalogModel.swift` and
  `LibraryCatalogView.swift` changed here (reach windows and the Timeline-mode gate); the window rule now lives in
  `Core/Views/NearWindow.swift`, shared by the Library and the Timeline. Rebase onto it.
- **The settings effort:** `ExplainerLine` is reusable for one-line-plus-(i) explainers.

## Born from this run

- **VX-330** (Backlog, project 13n): the Book Panel's collapsed one-note chapter row wears neither the waiting-ask icon nor the shared icon. Small, not marked pre-launch — yours to promote.
- Nothing else. VX-245 stays open for its six non-MCP lint sites (VX-283's).

**MOBILE PARITY:** nothing mobile-visible (the MCP door is Mac-only).
