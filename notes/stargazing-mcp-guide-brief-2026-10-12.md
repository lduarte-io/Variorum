# Brief for the stargazing.tech agent — the Variorum MCP guide page (updated 2026-10-14)

**The one rule that gates everything else:** the page must be live at its exact address before the Variorum
release that links to it ships publicly. That release's instructions to every connected AI end with "The guide to
this door: https://stargazing.tech/variorum/mcp", so an AI will fetch this page the moment it connects. Lillian
won't publish that release until the page is up. Tell her when it is.

**What to build:** one public page at **`https://stargazing.tech/variorum/mcp`** — exactly this path. Variorum's
app will tell every connected AI to read it, so the URL is load-bearing: if the site's structure can't host this
exact path, tell Lillian before choosing another, because the app's text has to change with it.

**When:** before the next MCP update ships. That update isn't released yet; it is the first release that links the
page. The releases already on the website don't link it, and a few things below arrive only with that
update: adding paragraphs to a note, duplicating a note for Compare, opening Compare for you, an AI checking its own
recent activity, and the labels on an AI's takes without the word "suggested". Lillian will say when the release
is near; there's no date yet.

**Who reads it:** two audiences at once — a person setting up an AI with Variorum, and the AI itself (an AI client
may fetch this page to learn what it can do). So: plain, scannable HTML; real headings; the facts in sentences, not
only in images; no content hidden behind tabs or scripts an AI fetcher wouldn't run.

**Voice:** calm, professional, clear — the voice of Variorum's own field guide. Sentence case everywhere (headings
included); never capitalize a word for emphasis; no marketing superlatives; no stacked dashes and asides; it should
not read as AI-written. Short paragraphs. Match the existing Variorum pages' styling on the site.

**Fact discipline:** the page content below describes the public release. Don't add claims beyond it. Where this
brief says something is the author's alone, keep that framing — it's a design decision, not a missing feature.
Describe what an AI can *do*, not the internal tool names (the appendix lists them for reference only).

**If you already built from the 2026-10-12 version of this brief,** apply both lists below. These were the changes
in the 2026-10-13 version:
1. *Setting it up:* setting a client up again now depends on the client — for Claude Code and Codex the new setup
   simply replaces the old one; for any other client, Variorum asks you to approve the new setup first.
2. *Suggest* now includes adding many takes or comments in one go, and deleting comments the AI left itself.
3. *Write new* now includes linking two notes as versions, and adding new paragraphs at the end of a note.
4. *Edit* is listed in full (it grew a lot), and the sentence "Every edit is bracketed by automatic commits" was
   wrong — only rewriting a take keeps its words before and after as commits. The corrected sentence is below.
5. *Seeing what it did:* the shared-with-AI icon now appears in the Library and the wing switcher too, and
   Settings ▸ MCP is organized in tabs.
6. *Closed app:* if Variorum isn't open, the AI's tools say so plainly ("Variorum must be open").

**If you built from the 2026-10-13 version,** these are the further changes (the page content below already
includes them):
1. *The gate* is now stated at the top of this brief: the page goes live first, then the release that links it.
2. *Setting it up:* the setup command sits in a code block with a copy icon in its corner. A new setup for a client
   that isn't copied from that client's own tab (Claude Code and Codex have tabs; other clients use the "any MCP
   client" setup) waits at the top of Settings ▸ MCP as "New setup for …", with no access, until you allow it.
3. *Read* now includes an AI looking up its own recent activity (only its own, since you last approved it), and
   pointing Variorum at Compare.
4. *Suggest:* takes an AI adds carry its name, plus its own short label when it gives one ("claude-code · english").
   The word "suggested" is gone from those labels. An AI may delete a comment it left only while the comment's
   words are unchanged; once you edit it, deleting it needs Edit.
5. *Write new* now includes duplicating a note for Compare (with a whole-wing share), and adding paragraphs at the
   end of a note is built.
6. *Edit:* new paragraphs can go anywhere in a note. Comments: an AI can bring back a deleted comment only if it
   already knows which one; it can't see deleted comments.
7. *What always stays yours:* an AI checking a new book's name only sees the books it can reach, so it may give a
   book the same name as one of yours it can't see.
8. *Seeing what it did:* undoing an AI's change never overwrites something you changed since; your typing is saved
   before an AI's change lands; a note an AI deletes while you have it open sends that window to the Library; the
   shared-with-AI icon also marks notes in the Pool and the Book Panel's rows, chapters included; Activity also
   shows when an AI checked its own activity.
9. *A new short section for the AI reading the page* (reading long notes in pages, checking that its writes landed,
   finding out whether a dropped call went through).
10. *Learn more inside the app:* the field guide's chapter is refreshed with this update.
11. *The appendix* has the final tool list.

---

## Page content (the facts, in a suggested order — write it in your own page voice)

### What this is
Variorum is a writing app for the Mac. It has a door for AI: a local MCP server (Model Context Protocol, the
standard way AI tools connect to apps). Any MCP client can use it — Claude Code, Codex, or any client that runs a
standard MCP stdio server. The door is closed until you open it, it only works while Variorum is open on your Mac
(if it isn't, the AI is told plainly that Variorum must be open), and it reaches nothing until you share something.
The phone app has no door.

### Setting it up
1. In Variorum, open **Settings ▸ MCP** and turn on **Enable the MCP server**.
2. On the **Connect** tab, choose your client (Claude Code, Codex, or any MCP client). Its setup command is in a
   code block; copy it with the copy icon in the block's corner. Run what you copied (for Claude Code, in a
   terminal), then start a new session of your client.
3. The first time the client connects, it appears in Settings ▸ MCP as a connection request. Approving it admits
   the client with no access yet — you then share what you want it to reach.

Each copied setup carries its own key, which ties the client's name to that setup; a connection under that name
without the key is refused. If you set Claude Code or Codex up again (a new setup, a reinstall), copy the setup
from that client's own tab and run it again: the new setup replaces the old one, and the client keeps everything
you shared with it. Any other new setup under a name you've already approved — for example one copied from the
"any MCP client" tab — waits at the top of Settings ▸ MCP as "New setup for …", with no access, until you allow
it, so a different tool can't quietly step into a client's place. Be clear about the limit, as the app is: this
tells tools apart, but it isn't a defense against other programs running as you on your own Mac.

### What you can share, and for how long
You share a **note**, a **book** (including notes added to it later), or a whole **wing** (Variorum's word for a
separate library). Each share has a level, and each level includes the ones before it:
- **Read** — read and search, and point Variorum's window at a note, book or wing, or open Compare with a note and
  up to three others beside it (only when you ask it to show you something).
- **Suggest** — add alternative versions ("takes") beside your text, one at a time or many at once, leave
  comments, and save lenses. Takes it adds carry its name, plus its own short label when it gives one (for
  example "claude-code · english"). It can delete a comment it left, as long as nobody has changed the comment's
  words since; once you edit one, deleting it needs Edit. It cannot change a word you wrote.
- **Write new** — create notes, books, chapters, tags and versions; file notes into books and chapters; set what
  a book collects; link two notes as versions so Compare pairs them; add new paragraphs at the end of a note; and
  duplicate a note, the way your own Duplicate as Version does, so Compare lines the copy up with the original row
  by row. Duplicating needs a share on the whole wing, because the copy lands in that wing's Pool.
- **Edit** — everything you can do at the keyboard on what you shared. On takes: edit, choose, label, lock,
  archive and delete them, and commit or restore a saved moment. On paragraphs: divide, merge, move, insert
  (anywhere in a note) and delete them (deleting a paragraph's only take deletes the paragraph). On notes and
  books: rename, archive and delete notes (deleted notes wait in the Trash for 30 days); rename, finish, archive
  and delete books; rename, move and delete chapters; reorder and take notes out of books. It can also edit and
  delete any comment, bring back a deleted comment it already knows of (an AI can't see deleted comments), and
  remove tags. When it rewrites a take, the take's words before and after are kept as commits (saved moments), so
  you can always compare and come back.

And a duration: **once** (one act), **until it disconnects**, or **always**. There's also an "open book" switch that
lets every approved client read the whole library; it starts off.

Once you approve a client, it can always look up what it did itself, since you last approved it — never another
client's acts, and nothing it couldn't already see when it acted.

### What always stays yours
- **Your daily Journal, entries made with ⌘J, and anything you mark Private** are never reached by a book or wing
  share. An AI can only reach one of those through a share on that one note, and "always" is never offered for
  them. An AI can't duplicate them either.
- Something an AI can't reach looks to it exactly like something that doesn't exist — it can't tell a private note
  from no note at all. That holds for book names too: an AI may give a new book the same name as one of yours it
  can't see.
- **Three acts are only ever yours:** marking something **Private**, **Sealing** a book (finishing it and freezing
  its text), and making a book **Own** its notes. An AI can't do these, but it knows about them and may suggest
  one when it would help you.
- Snippets are never reachable by an AI.

### What an AI can do for you — use Variorum to stay organized
The most useful thing an AI can do in Variorum is keep your work organized, in a form you can read:
- Put things into a note for you — a plan, a summary, research — instead of leaving it in a chat you'll lose.
- Create books and chapters, and file notes into them; tidy them later — rename, reorder, finish or archive.
- Tag notes, and make books that collect by tag rules ("everything tagged travel"), so they keep themselves sorted
  as you write.
- Offer a rewrite of a paragraph as a new take beside yours, instead of overwriting it — you choose which stays.
- Leave comments on paragraphs as review notes, without editing the text.
- Save a lens (a whole-document reading made of chosen takes), so you can compare its version against yours.
- Before a big revision, duplicate the note and revise the copy, so Compare lines the two up row by row; or draft
  a revision as a new note and link the two as versions, so Compare pairs them.

A few patterns from the author's own use: design documents where the AI's detail lives in takes beside a readable
summary; language homework where each answer is a take and corrections arrive as new takes; a bilingual book with
the translation in a take behind each paragraph; review of a draft where every suggestion is a take you can accept
by choosing it.

### Seeing what it did, and taking it back
- Every change an AI makes is one undo for you, named after the client (⌥⌘Z). If you've changed the same thing
  since, the undo leaves your change alone. Commits it saves stay, as yours do.
- If you're typing in a note when an AI changes it, your typing is saved first. If an AI deletes a note you have
  open, that window moves to the Library.
- Each change shows a short receipt with **Open ›** to jump to it (for two notes linked as versions, it opens them
  side by side in Compare), and **Show the AI's Last Change** (⌥⌘O) finds the latest.
- The **Activity** tab in Settings ▸ MCP lists what each client did, in words — including when an AI checked its own
  recent activity.
- A shared-with-AI icon marks what you've shared wherever it appears — books and gatherings on the Bookcase; notes,
  books and gatherings in the Library; notes in the Pool; the rows of the Book Panel (a book's contents beside a
  note), chapters included; wings in the wing switcher (⌘L) — and inside a note an indicator says whether it's
  shared. Each says who can reach it
  and why, with **Change…** and **Revoke**.
- When an AI asks for something it doesn't have, the ask waits quietly for you at the top of Settings ▸ MCP — it
  never interrupts you.

### For the AI reading this page
- Variorum tells you how its door works when you connect, and points you here.
- Long notes can be read in pages, and a page can carry a fingerprint of each take instead of its text, so you can
  check a whole note against your source cheaply.
- Most writes that store your text answer with a fingerprint of each take as stored, so you can confirm your words
  landed exactly.
- If a call's answer is lost (a dropped connection, a lost context), look up your own recent activity before
  trying again — it says whether the call went through.
- Help the author stay organized (the section above), and suggest Private, Seal or Own when one would help — only
  the author can set them.

### Privacy, in one paragraph
Your library is one encrypted file on your Mac. AI access is local: the door is a connection on your own machine,
grants live only on that Mac and never sync, and nothing is shared by default. What an AI client then does with
what it reads is up to that client and its provider — share accordingly.

### Learn more inside the app
Variorum's field guide (the book that ships with the app) has a chapter, "AI & the MCP door," that walks through
all of this with the app's own buttons. The chapter is refreshed with this update; a library that already has the
guide keeps its older chapter until Help ▸ Restore Tutorial… is used, which moves the old guide to the Trash and
adds a fresh one. The same command brings the guide back if it's been deleted.

---

## Appendix — the tool names (reference only; the page describes acts, not these names)

As of the update this page goes live with (64 tools).
- **Read:** list_books · list_notes · read_note · search · export_note · show_in_app · list_my_activity
  (list_my_activity needs no share: every approved client has it)
- **Suggest:** add_take · add_takes · add_comment · add_comments · delete_comment (its own, words unchanged) ·
  save_lens
- **Write new:** create_note · import_document · create_book · create_section · add_note_to_book ·
  file_note_in_chapter · apply_tag · set_book_rule · save_version · link_versions · insert_blocks (at a note's end;
  anywhere else needs Edit) · duplicate_note (needs a wing share)
- **Edit:** edit_take · choose_take · set_take_label · lock_take · unlock_take · archive_take · unarchive_take ·
  delete_take · save_commit · restore_commit · rename_commit · adopt_lens · delete_lens · divide_block ·
  merge_blocks · move_block · delete_block · put_back · set_block_name · set_entry_date · rename_note ·
  archive_note · unarchive_note · delete_note · move_note_to_wing · rename_book · finish_book · reopen_book ·
  archive_book · unarchive_book · delete_book · rename_chapter · move_chapter · delete_chapter ·
  move_note_in_book · remove_note_from_book · edit_comment · restore_comment · remove_tag

---

## Note for Lillian (not for the page)

This version folds in what VX-246 built (the setup keys tied to their tab, the waiting setup, comment deletes that
check the words, book names checked only against books the AI can read, your typing saved first, the undo that
never overwrites you, the icon's places) and what the VX-336 run built (paragraphs added to a note, duplicating a
note for Compare, Compare from the AI, the labels without "suggested", the AI's own activity, paged reads and the
write fingerprints, and the instructions that link this page). It can go to the site agent as one message.

Two things may still move before the release: the field guide chapter's final wording and title (VX-336's last
unit rewrites the chapter; if its title changes, the "Learn more" section changes with it), and any pane words
your VX-234 review renames. The gate at the top is yours to call: publish the release only after the page is live.
