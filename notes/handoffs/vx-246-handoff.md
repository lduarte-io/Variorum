# VX-246 handoff — the MCP door's fixes: security, undo, your editor vs the AI, badges (2026-10-14)

**Run:** VX-246 "Run: MCP door fixes & AI docs" · «PR #N, merged to `main` as a merge commit» · the record
`notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md` (your rulings, the orchestrator's provisional rulings, every unit
record, both ladder rounds, the stage log) · built overnight 2026-10-13/14 under your mandate: *"continue on through the
night ending in a merge to main … Rule provisionally in my absence and leave me a handoff with any needed information
to note down."*

*(DRAFT — written at PHASE A, before the merge. Every «…» is filled at the closeout's last step.)*

## What to know first

- **The security gap from 0.9.5 is closed in this build.** VX-258 shipped: a setup key copied from a client's own tab
  (Claude Code, Codex) carries that client's name, and any other new setup under a name you approved waits in Settings
  ▸ MCP ▸ Waiting for your Allow. So the "this build is yours alone" rule on VX-184's build ends here. 0.9.5 on the
  website still has the gap; publishing this build is your call (release notes drafted, shown to you and approved
  first, as always).
- **Only the fixes merged.** The night's merge carried the four units that fix the door and your editor. The new wire
  tools and the AI's docs (the other four units) moved to a new run, **VX-336 "Run: MCP wire tools & AI docs"**,
  which hasn't started. That split was a provisional call made overnight (ruling 3 below), so you can reverse it.
- **Your app in `/Applications` is refreshed** (this was the night's last merge): «Variorum build N», a Release build of
  merged `main`, with an A1 copy of your real store first. It also carries VX-282's editor and notes fixes, which
  merged just before this one.
- **Nothing to do for the AI clients you already use.** A client whose key you approved keeps connecting with it. If
  you re-run Claude Code's setup (or Codex's), the name moves to the new key with no clicks, as before. A setup copied
  from **Any MCP client** under a name you already approved now waits in Waiting for you: "New setup for ‹name›",
  with Allow and Don't allow. If a client of yours ever shows up there, Allow is the road.

## Your checklist

1. **Ratify or reverse the provisional calls: QUESTIONS #220.** Each was built as stated, with a line to reverse it:
   - **Setup keys:** a key from one client's tab used under a different approved name waits for your OK · what a
     waiting connection sees (no tools, the waiting sentence) · one waiting setup per name, the newer replacing the
     older · the wait logged once in Activity · the client's name in plain text inside the key · the "New setup" row
     leads Waiting, with Allow and Don't allow equal · Activity words the wait as an ask. (The bind arm is already
     yours: *"i ratify what you built"*, 2026-10-13.)
   - **Comments:** once you edit an AI's comment, on any device, deleting it needs edit access (the record keeps a
     digest of the AI's words) · a comment an AI wrote before this build counts as not its own, so it needs edit
     access to delete.
   - **Your editor vs the AI:** before an AI act that could meet your typing, every open note's unsaved typing is
     saved, not just the act's note · the few-millisecond window left after that is accepted.
   - **Undo:** an undo that finds its act already reversed changes nothing, says so ("Nothing to undo — ‹label› was
     already undone or changed since."), and drops the entry · it speaks as a refusal toast, not a quiet receipt · an
     entry with several parts moves only the parts still in its own state · a redo never revives something deleted
     another way (your Trash, another device) · your own ✓ Make this the note undoes block by block.
   - **The orchestrator's three overnight rulings:** a scripted client stood in for a real one on the timing test
     (Claude Code can't answer inside your 500 ms autosave pause) · when an AI deletes the note showing in your other
     pane, that pane goes to the Library and your caret stays where you are — on every road, your own Delete included ·
     the merge scope (the fixes now, the new tools and docs as VX-336).
2. **The release-notes line is yours.** 0.9.5's notes say "Running a client's setup again simply replaces the old
   setup and keeps everything you shared — no need to deny it first." (`ReleaseNotes-0.9.5.md:9`). That now holds for
   a client's own tab; a setup copied for any MCP client waits for your OK. Whether the next notes say so is yours.
3. **Your wording pass, VX-234, has this run's pane words** (each where it renders):
   - Waiting's row: "New setup for ‹name›" · "Connected as ‹name› (version ‹v›) with a setup that wasn't copied for
     it, ‹age›. It reaches nothing until you allow it; allowing moves the name, with its grants, to this setup." ·
     Allow · Don't allow · after a press on a setup that's gone: "That setup isn't waiting any more." While the ask is
     fresh the detail reads "…copied for it, now. It reaches…" (a wording note from the live round).
   - Activity: "‹name› asked to use a setup that wasn't copied for it" · "‹name› took the new setup you allowed,
     which replaced its earlier one" · "‹name›'s new setup wasn't allowed".
   - The Clients tab's (i) and the Connect tab's line under the code block now say the tab rule.
   - The two undo refusals: "Nothing to undo — ‹label› was already undone or changed since." · "Nothing to redo — it
     changed again after ‹label› was undone."
4. **Kick off VX-336 when you want it.** Its plan is `notes/plans/mcp-pane-and-docs-kickoff.md` (the kickoff message
   at its top). Its members: VX-267 · VX-253 · VX-252 · VX-255 (the write tools' shapes) · VX-311 · VX-298 (Compare
   from the wire) · VX-254 · VX-256 · VX-261 (the agent's read-backs) · VX-197 (the AI's docs, last). **The stargazing
   gate travels with it:** a build whose AI instructions link `https://stargazing.tech/variorum/mcp` ships only after
   that page is live, and VX-336's docs unit appends its changes to the brief for your site agent.
5. **Try it in the refreshed app (only you can open your real store):**
   - Have Claude Code rename a note, rename it back yourself, then press ⌥⌘Z: it should say "Nothing to undo — …"
     and leave your title alone.
   - Type in a note while Claude Code edits or deletes in it: your last words should survive.
   - With two panes open, have Claude Code delete the note in the pane you're not typing in: that pane goes to the
     Library, and your caret stays put.
   - A long fanned note in a book's Outline: each fanned paragraph's badge sits at its own line, including after you
     resize the window.
6. **The field guide changed one sentence** (lesson 2 of the MCP chapter, the setup rule). It reaches your library
   only through Help ▸ Restore Tutorial…, which moves the old guide to the Trash and makes a fresh one. VX-336 rewrites
   that chapter, so waiting for it is fine.

## What shipped

- **VX-258 — setup keys tied to their tab.** Claude Code's and Codex's setups carry the client's name in the key;
  re-running a client's own setup moves its name with no clicks. Any other new key under a name you approved waits in
  Waiting, reaching nothing, until you press Allow (which serves that same connection at once) or Don't allow. Deny
  and opening a library from another Mac clear the waits.
- **VX-259 — book names.** When an AI names a book, the name is checked only against books it can read, so it can no
  longer learn the name of a private book by bumping into it. Your own doors keep the full check.
- **VX-260 — your edit makes a comment yours.** After you edit an AI's comment (on any device), an AI with suggest
  access can't delete it; it hears your ruled sentence.
- **VX-279 and VX-280 — door internals.** The server no longer risks closing another connection's socket number, and
  `save_lens` reads only the takes it was given.
- **VX-276, VX-277 and VX-119 — undo never writes over you.** An undo or redo whose act you've already reversed by
  another door does nothing and says so, for your own doors and the AI's alike (all 85 undo registrations checked).
- **VX-275 and VX-323 — your typing comes first.** Before an AI act that could meet a take you're typing in, your
  unsaved typing is saved; if the act removes the paragraph your caret is in, the caret lands as your own Delete Block
  would land it; a note the AI deletes leaves every pane showing it, and your focus stays where it was.
- **VX-230 and VX-231 — the faces after big writes.** No more dark disc or stray badge at the first paragraph: each
  fanned paragraph's badge sits at its own line, in Write and in a book's inline editor, after a resize too. The
  Bookcase row's note and word counts follow a note joining from outside it.
- **VX-318 was checked and found hollow:** the socket reader can't outlive its connection. Nothing changed, and its
  test stays as a guard.

## How it was checked

- **Every fix has a test that failed on the old code** and passes now, and each was failed again by reverting the fix.
- **Five stage windows on the dev store**, each restored byte for byte afterwards: Mac test batches of 1,084, 1,470,
  1,825, 1,946 and 1,838 tests (every red accounted for: the standing VX-115 and VX-167 ones, and three that the
  follow-up units U4b and U4c resolved); walks in both voices; and live rounds with a real Claude Code 2.1.299 (and a
  small scripted client where a waiting connection or a millisecond timing needed one) for every setup-key case, the
  book-name check, the comment rule, the undo refusals and the pane leaving a deleted note.
- **The review ladder, closed at round 2.** Round 1, the Fable review: 1 minor (the field guide's setup sentence was
  no longer true — fixed) and 3 nits, all fixed. Round 2, Opus at max: 2 minor and 5 nits, all fixed (none changed
  behaviour) except one, which belongs to the phone (VM-16, below). The orchestrator checked the final fixes line by line.
- **The numbers:** headless MCP 240/51 · core 2,841/329 · workbook 40/6; the merge-moment run of the whole Mac test
  target «N tests in M suites — the standing reds named, no new red».

## Tickets born from this run

- **VX-323** (born and fixed here): AI rewrites, divides, merges, locks and commits read the saved text, never your
  unsaved typing — fixed by the same save-first step as VX-275.
- **VX-318** (closed as not a bug; its test kept).
- **VX-324:** the Takes board's Lock, Archive and Delete-take doors may not save your typing first (your own doors;
  noticed, not reproduced; a probe comes first).
- **VX-327:** callouts, comment cards and seams may pile at the top in a book's inline editor after a resize, the way
  the badges did (a probe comes first).
- **VX-328:** with two panes open, the Library in the right pane draws past the divider.
- **VX-333:** some Mac tests wait the wrong way and may read a moment too early (a sweep).
- **VM-16** (the phone): the phone's undo door still says "Undid: …" when nothing was undone, and its Redo offer then
  runs a different, older entry. It's two lines, the Mac door's fix, and should land with or before the phone takes
  this build's core.
- **VM-17** (the phone): its fan badges may pile at the first paragraph on long notes, like VX-230 on the Mac (a probe
  comes first).
- **VX-336:** the follow-on run (above).

## For the other runs

- **VX-336:** start from its kickoff message. U5's brief is drafted in VX-246's record; U6 and U7 have only their
  sizing rows there. Every new tool must answer whether it meets your typing (the save-first list) and whether each
  undo half changed anything; the compiler asks both.
- **VX-283:** when an AI deletes a note, the pane leaves it on the one road (`.variorumNotesDeleted`, from
  `MCPDoor+HerEditor.swift`); a sync arrival or a book deleted with its notes should post on the same road, never a
  second one. `WorkspaceModel.select` gained `takingFocus:`.
- **The phone (VM-16, VM-17):** the measured TextKit facts are in `notes/TEXTKIT2_NOTES.md` §3 (the VX-246 block).

## Left on disk

- «The dev store's A1 copies from this run's windows (`scale-prestage-20261014T…` in the DEV container's
  `Backups/safety-copies/`) — kept or pruned by the coordinator; the list at the closeout.»
- «Your real store's A1 copy from the refresh — its path.»
- Nothing else: the run's screenshots, logs and build folders are deleted after the merge.

**MOBILE PARITY:** PL-54 in `notes/MobileSoul.md` — the undo rule reaches the phone through shared code and VM-16 must
land with it; VM-17 probes the badges; nothing else is mobile-visible (the MCP door is Mac-only; a comment you edit on
the phone reaches the Mac by sync, where the rule applies).

## For a fresh session

Everything lives in `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`: its CLOSEOUT RECORD names what landed
where. The next MCP run is VX-336; its plan, `notes/plans/mcp-pane-and-docs-kickoff.md`, is self-contained.
