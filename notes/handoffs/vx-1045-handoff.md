# VX-1045 — the Nov 24 sitting: your handoff

**STATUS: closed 2026-11-24. Variorum 1.5 (build 13416) is published and installed on the Pro. The record is
`notes/plans/vx-1045-nov-24-sitting.md`.**

## What happened, in plain words

You asked for five things: the recent VX handoffs handled, Apple's agreement signed, 1.5 released, the Ambient PR
merged with its tickets tagged, and the coordinator's held items dealt with. All five are done.

- **The handoffs.** You ruled the open calls from the search run (VX-980) and the AI door run (VX-981). Almost
  everything stays as built. The decisions are in `notes/QUESTIONS.md` (#276 addendum 2 and #278's addendum), in your
  words.
- **The parity audit.** Its gaps became one umbrella, VX-1046, with every buildable ticket in Todo at your word. Its
  twelve exceptions (things that stay yours at the keyboard) are now written into the AI door's spec.
- **The Ambient PR.** PR #8 merged. A new "Ambient" label sits on all fourteen Ambient tickets.
- **The coordinator's items.** The five skill lines landed. You reinstalled watchman yourself. No simulator ticket.
- **The slow open (VX-1013).** Sized and measured; now High and Todo for your next umbrella.
- **1.5.** You accepted Apple's agreement, the first-run check passed again, you had the notes rewritten in a plainer
  style and approved them, and the release was built, published and installed.

## Your checklist

- [ ] **Open 1.5 on the Pro when you like.** It is installed and was not launched. The first open makes a one-way
  change to the library's local database, so 1.4 cannot open that library afterwards. A safety copy from just before
  the install is in your library's `Backups/safety-copies/A1-20261124-pre-1.5-install/`.
- [ ] **Restore the field guide** (VX-1073): Help ▸ Restore Field Guide… on 1.5. Its AI chapter changed.
- [x] **The Air:** on 1.5 by Sparkle, the same evening (your word).
- [ ] **The wording pass.** You sent no edits, so every new sentence from the two runs is still provisional. The lists
  are in `notes/handoffs/vx-980-handoff.md` and QUESTIONS #278.
- [x] **The twelve exceptions:** confirmed after you saw the list ("seem fine to me for now"). They stay written in
  `notes/MCPSpec.md` beside the audit's pointer, so a later change has something explicit to change.
- [x] **VX-1046's priority:** High, confirmed.
- [ ] **Still yours from the two runs:** VX-370 (a second MCP client on the Pro) and VX-1009 (searching for symbols, a
  design sitting; it stays marked as yours). VX-1068 (what a Snippets grant for AI would name) went to Backlog at your
  word.
- [ ] **Ambient, from its own handoff** (`~/dev/ambient/notes/vx-1035-handoff.md`): name the version, install it on
  the Air, and the taste list. None blocks anything.
- [ ] **The Nov 22 sitting** (branch `vx-1033-nov-22-sitting`) still owes its close, and whether it merges is yours to
  say. It now conflicts with main in `notes/SurfaceContracts.md`, a notes-only conflict its merger resolves.

## What changed for you in the app

Nothing was built at this sitting. 1.5 carries what the search run and the AI door run built on November 19. Its
notes, as you approved them, are `App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-1.5.md`.

## The release, with its evidence

- **The first-run check, again.** It had passed before the phone runs merged; those changed shared code, so it was
  owed again. On the code of `703c42173`: the headless drill ran 11 of 11 tests green, and the scripted walk passed
  both arms (a new user turning sync on, then a second device joining). The dev store was set aside whole and put
  back with all 239 files' checksums unchanged. The walk's screenshots were withheld by the words guard, the known
  behaviour on this macOS version, so its log is the evidence.
- **The whole Mac test suite was not re-run.** It passed on the last tree that changed Mac code (6,435 tests, the
  phone runs' merge gate), and nothing the Mac compiles has changed since.
- **The notes.** Your words: "I don't like this type of riddler update … I want them rewritten in a more
  straightforward style of communication." The rewrite states each fix as the bug and its fix. Your answer: "yeah
  that looks good". The What's New tests ran 11 of 11 green on the rebuilt app.
- **The build.** From main `83a15ac0e` (PR #22's merge), build 13416. Apple's notary accepted the app and the disk
  image; Gatekeeper accepts both; the app inside the final disk image passed 58 of 58 checks. `Variorum-1.5.dmg`,
  33,954,921 bytes, sha256 `5fabddcb6777cd658a80b41a187a873a45cb78260e3a5efbaaa2b488ed8007c7`. The appcast was made
  with no Keychain prompt and verifies.
- **The publish**, at your word ("ok go ahead and publish this and push it over sparkle and all that."): the disk
  image uploaded first and downloaded once, byte-identical to the build; then the appcast and the site's version
  bump, deployed; the live appcast is byte-identical to the built one and the page shows 1.5.
- **The install on the Pro.** I read "and all that" as covering it, since the release run is what puts the released
  build on your Mac. A fresh safety copy first, each of its six files compared with its source; the published app
  staged, verified, swapped in and verified again; nothing launched. The 1.4 app is in the Trash.

## Things that went sideways

- **The site repo on the Pro was 20 commits behind its remote.** Deploying it as it stood would have rolled the live
  site back to its November 10 state. I pulled first. Worth knowing for any deploy from the Pro.
- **An untracked folder would have stopped the build.** The Nov 22 sitting's local frames of your recording sit in
  the main checkout, and the release script refuses any untracked file. The folder is now on the ignore list, so the
  frames stay local and can no longer be committed by accident.
- **I wrote three time stamps in the record by guess** and had to correct them from the clock and the stage log.
- **Linear closed VX-997 by itself** when PR #8 merged. Its open Low tickets stay seated under it.
- **Three Debug preference values** written by the drill's test host were left as they are, with the coordinator's
  agreement. They are ordinary test-host writes.

## Canon

`notes/SurfaceContracts.md` and `notes/MCPSpec.md`: the calls you ratified lose the word PROVISIONAL, and the twelve
stated exceptions sit beside the parity audit's pointer. Neither file is in the loaded set. `Tools/canon-size` on this
branch: `143606  total (harness limit 150000, headroom 6394)`, no crossing.

## Mobile parity

Nothing mobile-visible. The sitting built no code, and 1.5 is the Mac's release of code the phone already carries.

## Tickets filed

- [ ] VX-1046 (High, Umbrella, Todo): MCP parity, the AI door catching up with the keyboard.
- [ ] VX-1047 (Medium, Feature, Todo): extract a passage into its own block over the AI door.
- [ ] VX-1048 (Medium, Feature, Todo): move a passage out of a take into a new take.
- [ ] VX-1049 (Medium, Feature, Todo): turn a take, or a block's whole fan, into blocks.
- [ ] VX-1068 (Medium, Feature, Needs Lillian): Snippets for AI, what a grant would name.
- [ ] VX-1073 (Medium, Task, Needs Lillian): restore the field guide on 1.5; the Air's update.
- [ ] VX-1050 (Low, Feature, Todo): rename a tag and its subtree.
- [ ] VX-1051 (Low, Feature, Todo): word targets on notes and books, and a book's note limit.
- [ ] VX-1052 (Low, Feature, Todo): put back a note, book or chapter the client deleted.
- [ ] VX-1053 (Low, Feature, Todo): archive and unarchive a block; read the tray's Archived view.
- [ ] VX-1054 (Low, Feature, Todo): pin a note to the top of a book; read pins.
- [ ] VX-1055 (Low, Feature, Todo): move a take earlier or later in its fan.
- [ ] VX-1056 (Low, Feature, Todo): rename, duplicate and re-pick a lens; promote a lens to a note.
- [ ] VX-1057 (Low, Feature, Todo): put back a released original; bring a lineage relative or commit back as a take.
- [ ] VX-1058 (Low, Feature, Todo): duplicate a book.
- [ ] VX-1059 (Low, Feature, Todo): diverge a note for one book.
- [ ] VX-1060 (Low, Feature, Todo): shelves.
- [ ] VX-1061 (Low, Feature, Todo): rename a wing.
- [ ] VX-1062 (Low, Feature, Todo): a book's journal setting and a gathering's hide-owned setting.
- [ ] VX-1063 (Low, Feature, Todo): Compare's outline note.
- [ ] VX-1064 (Low, Feature, Todo): list what waits at a book's Arrivals.
- [ ] VX-1065 (Low, Improvement, Todo): read starred, locked and sealed.
- [ ] VX-1066 (Low, Feature, Todo): list the tags the notes in a client's reach wear.
- [ ] VX-1067 (Low, Improvement, Todo): `list_wings`' description names six of the ten tools that take a wing id.
- [ ] VX-1069 (Low, Improvement, Backlog): the band stops quoting a dash typed beside a tag.
- [ ] VX-1070 (Low, Bug, Backlog): a toast covers the cards band.
- [ ] VX-1071 (Low, Improvement, Backlog): an unapproved client that only lists its tools raises no request.
- [ ] VX-1072 (Low, Improvement, Backlog): after "Don't allow", the waiting client hears nothing.
- [x] VX-1045 (High, Task, Done): this sitting.

Changed on the board: VX-1013 to High and Todo · VX-1026 seated under VX-1036 · VX-159 to Medium, and it with VX-145,
VX-146, VX-147 and VX-148 seated under VX-1046 in Todo · VX-1017 parked · VX-460, VX-368 and VX-1028 closed.

No next plan is owed by this sitting; you order the umbrellas.
