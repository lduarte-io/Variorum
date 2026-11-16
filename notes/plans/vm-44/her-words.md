# VM-44 — her words (verbatim; the requirements every brief quotes from)

Draft working record, not canon. Quotes are exact; anything outside quote marks is the orchestrator's note.

## 2026-11-12, the kickoff message

- "The mobile app is SO behind right now and it kind of drives me insane."
- "There's significant lag when going to the quick entry box, when going from the quick entry box into a note"
- "there are no different wings (!!) so everything just shows up in one bunch but it's hard to find items in the library."
- "I want to get everything smoothly working again and I know there are a lot of already filed catch up tickets but it's time for hte mobile app to be better."
- "It's also got weirdly tiny font a lot of the time"
- "I don't like that there's a whole pale band around the quick click buttons rather than just hte buttons themsleves"
- "the box looks awkward"
- "many of the button affordances are absolutely tiny"
- "it just needs a lot of love and attention. yes it's missing features but also what's already there is seriously behind too."
- Compare: "having thought about it I would like to have a compare mode, maybe with the notes as different tabs that you can swipe between and still have the notes line up  block by block? that's just one idea on it and again, probably won't even be in v1 of the mobile app"
  - Note: MobileSoul §4.5 lists Compare as a ruled exclusion; this reopens it, after v1. Record the reversal at approval.
- The goal: "I want to get the mobile app done and out there so that people can start actually using variorum synced between devices (since very few people have multiple macs)."
- The output: "detailed plans and linear tickets with mockups on every feature that should be built, improvements across the board, and an order. I'd generally group tickets into umbrellas with 5-10 related tickets, and waves of 2-4 umbrellas at a time."
- The cast: "you can have up to 2 fable subagents at a time working on making plans / mockups ... you can use opus subagents to look for everything that is missing ... don't have more than 10 subagents at any time though (2 fable, 8 opus) ... do not interpret this as 'spawn 10 subagents'"
- "we shouldn't start writing code (unless you can't run the app because something is broken, in which case you can fix that to unblock everythinge else)"

## 2026-11-12, second message

- Wings: "I have 9, so UI options should work well with many. a quick swipe between them and also a dropdown option would be nice."
- High priority: "app staying unlocked for a few minutes damn."
  - Orchestrator's note: today the phone locks every time Variorum leaves the screen under Castle (`MobileRelock.swift`, `locksOnLeaving`). CORRECTED after audit D: the code comment calls the lock-on-background rule "her words", but audit D traced it to the 13p planner's item (g), approved by the architect — NOT a ruling of hers. Hers is decision 18 (re-lock on sleep / screen lock always on; idle 5·10·30·never). CastleRules is silent on re-locking. So a grace window reverses no ruling of hers; see `audit/D-protection-sync-launch.md` §2.
- High priority: "showing preview more lot apple notes so i know what each note is."
  - Orchestrator's note: the phone's Library rows carry no body preview today.

## 2026-11-12, third message (sync, the fan-out, her phone)

- "you can maybe sync with the dev store if you'd like, not sure if you want to add that to the testing / complexity. you can seed a new library instead but that is an option."
  - Orchestrator's note: seeded library chosen (the walk's fences keep the Debug phone app signed out).
- "yes on the audit fan out, I will plug my phone in later."

## 2026-11-12, fourth message (the lock, the look)

- "fully closing the app rather than just backgrounding it should make the library lock automatically though."
- "and a lock now button should be there like the mac."
- "the overall look of the app is fine aside from how everything is weirdly small and spaced, but honestly, just use the mac app as your visual direction. the study mode especially. the sea greeen theme"
  - Orchestrator's note: so the design pass is NOT a new look. It is the Mac's look (Study voice, the sea-glass palette) at phone-right sizes and spacing. Graders weight size, spacing and touch over restyling.

## 2026-11-12, fifth and sixth messages (the folder, her phone)

- On the working folder outside the repo: "honestly it's fine to build local until the sitting I understand your reasoning."
- "you're right, my phone is not syncing right now and honestly, I need a build on my phone *today* to fix that, even if nothing else is fixed."
  - Orchestrator's note: VM-45 minted (Urgent). One Opus agent prepares the device build and an install runbook; the install waits for her phone on the cable.
- "I'll need you to put mockups on my air and give me commands to open them."
  - Orchestrator's note: the folder is mirrored to the Air at `notes/plans/vm-44/` (rsync from the Pro, minus raw recordings and instruments); re-pushed whenever mockups land.

## 2026-11-12, the first sitting (at the Pro)

- The safety copy and the label (VM-45): "yeah, we can do a safety copy for the phone. and the version label is fine."
- How the sitting runs: "you should open these files for me on my pro in the order that we're going to go through them in, then discuss each file one by one with me as I get to it, for whatever we need to decide with that file. and after explaining you can use the question tool."
- RULED, NT-1: "I think return should make a new block, as on the mac."
- On the designers' proposed lines: "I think we need to word things more simply."
  - Orchestrator's note: applies to every drafted line in the mockups; proposed words get shorter and plainer before her wording pass.
- VM-45, the phone's sync row: she confirmed it reads "Sync paused, needs update".
- The keyboard bar (`sketches/LK-4-LK-3-keyboard-bar.html`), her answers verbatim:
  - Is the white strip the band: "i meant in the text editor but i also dont like that white strip. what the Aa sits on."
    - Orchestrator's note: so the white strip goes; WHICH band she first meant is still to confirm (possibly the wide capsule around the formatting buttons).
  - The resting bar: "i like the one capsule being right aligned but i actually don't generaly want to show receipts there for something as normal as \"new block added\". i feel like it'll feel too noisy. but then when you click on the ... it could expand into common things like undo, redo, etc. that way some options in ... could be faster to click on?"
  - The formatting strip: "it should be a setting between all eleven in one menu or the seven big, rest in menu. both are good options, i'd do the eleven in one row but that wouldnt work for someone with poor vision"
  - Which band, asked again: "The white strip only" (the capsule around the formatting buttons is fine).
  - The formatting strip's default: "Seven big by default" (the compact eleven is the opt-in setting).
- RULED, SW-1 (`sketches/SW-1-wing-swipe.html`): "On the wing title (left)" — swipe the title band to step wings, dots show the place among nine, tap the name for the dropdown; the page keeps the Starred · Bookcase · Library swipe.
- RULED, SW-3 (`sketches/SW-3-home-screen.html`): "Bookcase gets the screen" — one scroll for the Bookcase; the capture box is a one-line field at the foot that grows with what is typed. (Reverses R27's half-screen writing area.)
- RULED, SW-4: "New line; File and Open buttons" — Return in the capture box is only ever a new line; File saves and clears, Open saves and opens.
- RULED, LK-5: "Words on a chip" — the bottom bar is three words at 17 pt, the current one on a chip, 56 pt targets.
- RULED, the Today button beside the capture box (the designer's addition): "Keep it".

## 2026-11-15, the sitting resumes (after the account switchover; she closed the computer for a few days)

- VM-45: "sync is confirmed working between my phone & computer."
- The record moves into the repo: "it's time to stop hiding all of this from the repo … I committed to being open source and building in public. people seeing that there were other mockups and then what I went with isn't bad, if we normally commit mockups anyway. and I don't want to do this weird halfway in halfway out thing - for business cases I'll specifically tell sessions to go to that other repo".
- On this file: "her-words.md is fine - I'm not publishing all of my prompts moving into the future, but I'm also keeping in mind that what I say is stored in the record and the record is public. it's not a problem, this is what I signed up for with building in public and having all of my notes and AI notes public."
- Screenshots: "i thought we normally already kept heavy screenshots out of git anyway?" (Yes: the `*-screens` folders are gitignored; this record follows it.)
- How efforts merge: "normally when a session completes its work under the overnight mandate I have it just merge its PR, for example, and take care of the handoffs after but before release. so not everything is going to be a draft PR I personally approve - that's not how I've worked in the past either."
- The guard: "should we make a pre-push guard for private identifiers? … if we do need that, you can start a subagent for it." (VX-996, started.)
- "you can start the export and share and compare concept for after v1 on subagents." (Started.)
- "help guide me through the remaining mockup files and then you can make the full plan, the linear tickets, etc."
- RULED, LS-1 (`sketches/LS-1-note-rows.html`): "List, one preview line (middle)" — title; the time and one line of the note's words; where it lives.
- RULED, journal rows: "Day first" — the entry's day is its name; the line under carries the time and first words (the Mac's rule).
- RULED, BK-1 (`sketches/BK-1-bookcase.html`): "Chip row above the list".
- Home, wings and capture mockup (`mockups/home-wings-capture.html`):
  - Wing management on the phone: "#9 seemed like a fine approach - it can be hidden behind 3 dots but some people will only use the phone app, and being able to create but not delete wings would make it awful"
    - Orchestrator's note: so the phone manages wings in full (make, rename, delete, move contents — whatever the Mac does), tucked behind a ⋯; frame 9 is the approach.
  - Opening a note from another wing: "Follow the note" (the Mac's rule).
  - The capture marks: "Keep the helper keys".
  - The bottom bar on pushed screens: "Roots and lists, not notes".
- Library and search mockup (`mockups/library-and-search.html`):
  - Room names: "Pool and Snippets".
  - Snippets on the phone in v1: "View, add, edit, delete" (dragging a snippet into a note stays Mac-only).
  - Search scope: "i think there's already a ticket made potentially for being able to search through all wings on the mac. look for if there is. either way, it should be current wing with a switch to all. if there's not one for mac, mint it"
  - Note actions in v1: "Duplicate (both kinds), Multi-select, Undo on archive, Move / copy to wing" — all four.
    - Orchestrator's note: the Mac ticket exists — VX-987 (\"A wing blind search — search across all wings, not just the current one\", Backlog). Nothing minted; the phone and Mac switch share that ruling.
- A book and Arrivals mockups (`mockups/a-book.html`, `mockups/arrivals.html`):
  - The book strip on a note opened from a book ("3 of 12 · Chapter", ‹ ›): "At the foot".
  - The rule editor: "Simple editor" — any/all of tags, starred, not-tag; a nested rule shows as a locked row.
  - The "Open Arrivals first" button on the Finish confirm: "Keep it".
  - Arrivals: "Full-screen review".
- Books, by a word:
  - Book views in v1: "Contents and Read" (an Index and a paged reader come after v1).
  - Shelf management: "Full, behind a ⋯".
  - A book's word target and note limit: "Show and edit both".
  - The Journal's new entry: "Foot of the Journal" (the Today button keeps opening the day's first entry).
- Note-write mockup (`mockups/note-write.html`):
  - Which acts show a line: "Only removals and refusals" — nothing for ordinary acts; a short line with Undo when something leaves the page, and for refusals.
  - The ⋯ quick row: "Undo and Redo, Comment", and on Commit: "will commits be easy to see on the phone? depends on how we do lineage, but i lean towards the commit / lineage being easily accessible as a core feature. but if lineage is hard to access, not sure if commit needs to be easy. thoughts? and how would the commit box show up and let you write in it?"
  - The masthead: "Yes, but no place readout" — title and chips scroll away; a slim bar with the title stays; the jump menu opens from it; no "block 3 of 4".
  - A Read mode for a single note in v1: "Not in v1".
- Commit identity (2026-11-15): the commits made since the flip carried a personal email as author. Her word: "maybe we should just change my personal email address being the commit? … go ahead and rewrite that and force push main. and what do we need to change so it's not an issue going forawrd?" (The address itself is not written here.)
  - Orchestrator's note: the repo-local commit email is now the GitHub noreply address on both Macs; the rewrite of `main` is held for one confirmation because GitHub's pull-request refs keep the original commits (see the session's report).
- The ⋯ quick row: Commit joins it — "commit in the quick row - yes." (Undo, Redo, Comment, Commit, then the full menu.)
- Merge the record PR at the end of this sitting: "yes, that's fine."
- The commit identity, settled: "if it won't remove the address from github, it's honestly fine … this email is not like a secret, so it's not a big issue." History is left alone; new commits carry the noreply address.
- The home-folder path in two walk scripts: "not that worried about this, but we might as well fix it going forward."
- Usage: "we hit the weekly limit but now we have more. so if you need two subagents at a time that's fine. the fable designers doing the revision pass is fine."
- Takes and history mockup (`mockups/takes-and-history.html`):
  - "i like the takes badge. i also like being able to click on it to swipe between them at the bottom a lot, if that's what the mockup is showing. that's a way easier way to work with your existing takes than the current multi click menu and I love how fast that makes it."
  - History's doors (a row in the block menu beside Commit, and a History button on each take card, one sheet): "i think that makes sense for history - though there is a lineage element that isn't from any one particular take, not sure if you just access that from history."
  - The conflict take's signal: "seems fine as is."
- Comments and callouts mockup (`mockups/comments-and-callouts.html`):
  - Where the marks sit: "i'd keep the designer mergin - One cluster at the block's trailing foot; the glyph in the gutter. (the one that has a green pill)."
  - A half-typed comment: "yes, any way of closign keeps it as an unsent draft."
- The guard and binary files (VX-996's open question): "i don't think we need to scan binary files like screenshots necessarily? i'm open to changing my mind, but generally I think that I'm working now knowing that my direct feedback to you is going to be in the public record and that screenshots might not be too. so I am adjusting my own habits for work in public (very minimally honestly)."
- The Air: "i haven't been running any tests on the air or doing any direct development there, it's normally website changes and planning sessions at most." (So its newer Xcode is fine.)
- The guard's private list: "why can only I help with the token list? what's the deal with that?" (She was right to ask: the sweep's own rule files were on the Air all along. The list is now compiled from them on both Macs.)
- First run, where "I already use Variorum" lives: "I think I already use variorum welcome card is probably fine" — the welcome card on the Bookcase, no screen in front of it.
- VX-207's title reworded at her word; the one leftover user name in the old issues export fixed (VX-998).
- Outside contributors (QUESTIONS #275): "I'm not planning to have outside contributers so might not be an issue." (The guard stays as built.)
- VX-999 (the release scripts and the signing profile): "do the script fix - I still need to able to do releases."
- "let's just finish the loop on what needs to be done post flip now" — the orchestrator's list and its state are in the session's report; CLAUDE.md's Environment section now says where an effort's record lives and drops the retired mobile worktree.
- The lock mockup (`mockups/lock-and-protection.html`), her answers verbatim:
  - The dial's default: "this only matters for castle, right?" (Yes — a Standard library never locks. No other default was named, so the existing 10 minutes stands.)
  - The app switcher while the library is open in the background: "Show the page as today".
  - Where she lands after a real unlock: "the home screen but there should be a \"back to where i was\" button (doesn't have to be worded exactly like that)"
  - Lock library now: "there should be a lock icon at the top of the homescreen or in the bottom bar or something"
- The phone's app icon: "please change the variorum icon to being the actual variorum icon. that should just be done now." (VM-46.)
- Releases: "i only do run releases from the pro."
- Trash, Archived and tags mockup (`mockups/trash-archive-tags.html`), the designer's three additions: all kept — "Undo after deleting a tag, Unused-tags door in the Trash, Counts in the tag list".
- Export and share mockup (`mockups/export-and-share.html`):
  - Exporting a note: "Yes, ask which file" — just the text, or with takes and tags; Copy stays the on-screen words.
  - A book as a folder of notes: "this should be a thing after v1. in fact, file a ticket so that it's not just a mobile ticket - this is a good improvement for mac. put it on the todo list. and also, move the \"search not just in one wing\" out of backlog and into todo as well." (VX-1000 minted, Todo; VX-987 moved to Todo.)
- The Compare concept (`mockups/compare-concept.html`, after v1): "Takes first, then tabs".
- The short questions, her answers verbatim:
  - The Private mark on the phone: "follow the same only show it if an mcp is active elsewhere - users who don't have the mac app shouldn't see it"
    - Orchestrator's note: grants never sync, so the phone cannot know whether an AI client is approved on a Mac. What does sync is the mark itself and the `ai_marks` switch. So the phone draws the eye only where a mark exists and the switch is on — a phone-only user has no marks and never sees one. To confirm with her.
  - Voice and palette: "follow the library but if the phone has dark mode on, that shouldn't change what your mac is like (the device dark mode)" — voice and palette follow the synced library; light or dark stays each device's own.
  - The library doors (look inside, open, restore, send a copy): "After v1".
  - The lag trace: "Your real library".
