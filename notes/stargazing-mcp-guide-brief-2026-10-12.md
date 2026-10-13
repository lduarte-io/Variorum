# Brief for the stargazing.tech agent — the Variorum MCP guide page (updated 2026-10-13)

**What to build:** one public page at **`https://stargazing.tech/variorum/mcp`** — exactly this path. Variorum's
app will tell every connected AI to read it, so the URL is load-bearing: if the site's structure can't host this
exact path, tell Lillian before choosing another, because the app's text has to change with it.

**When:** the page must be live before the public Variorum release that links to it. That's the next MCP update,
which is not built yet; today's build (2026-10-13) is private to Lillian and doesn't link the page. Lillian will
say when the release is near. There's no date yet.

**Who reads it:** two audiences at once — a person setting up an AI with Variorum, and the AI itself (an AI client
may fetch this page to learn what it can do). So: plain, scannable HTML; real headings; the facts in sentences, not
only in images; no content hidden behind tabs or scripts an AI fetcher wouldn't run.

**Voice:** calm, professional, clear — the voice of Variorum's own field guide. Sentence case everywhere (headings
included); never capitalize a word for emphasis; no marketing superlatives; no stacked dashes and asides; it should
not read as AI-written. Short paragraphs. Match the existing Variorum pages' styling on the site.

**Fact discipline:** the page content below describes the public release. Don't add claims beyond it. Where this
brief says something is the author's alone, keep that framing — it's a design decision, not a missing feature.
Describe what an AI can *do*, not the internal tool names (the appendix lists them for reference only).

**If you already built from the 2026-10-12 version of this brief,** these are the changes:
1. *Setting it up:* setting a client up again now depends on the client — for Claude Code and Codex the new setup
   simply replaces the old one; for any other client, Variorum asks you to approve the new setup first.
2. *Suggest* now includes adding many takes or comments in one go, and deleting comments the AI left itself.
3. *Write new* now includes linking two notes as versions, and adding new paragraphs at the end of a note.
4. *Edit* is listed in full (it grew a lot), and the sentence "Every edit is bracketed by automatic commits" was
   wrong — only rewriting a take keeps its words before and after as commits. The corrected sentence is below.
5. *Seeing what it did:* the shared-with-AI icon now appears in the Library and the wing switcher too, and
   Settings ▸ MCP is organized in tabs.
6. *Closed app:* if Variorum isn't open, the AI's tools say so plainly ("Variorum must be open").

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
2. On the **Connect** tab, choose your client (Claude Code, Codex, or any MCP client) and copy its setup command
   with the copy button. Run what you copied (for Claude Code, in a terminal), then start a new session of your
   client.
3. The first time the client connects, it appears in Settings ▸ MCP as a connection request. Approving it admits
   the client with no access yet — you then share what you want it to reach.

Each copied setup carries its own key, which ties the client's name to that setup; a connection under that name
without the key is refused. If you set Claude Code or Codex up again (a new setup, a reinstall), copy and run the
setup command again: the new setup replaces the old one, and the client keeps everything you shared with it. For
any other client, Variorum asks you to approve the new setup before it takes over, so a different tool can't
quietly step into a client's place. Be clear about the limit, as the app is: this tells tools apart, but it isn't
a defense against other programs running as you on your own Mac.

### What you can share, and for how long
You share a **note**, a **book** (including notes added to it later), or a whole **wing** (Variorum's word for a
separate library). Each share has a level, and each level includes the ones before it:
- **Read** — read and search, and point Variorum's window at a note, book or wing.
- **Suggest** — add alternative versions ("takes") beside your text, one at a time or many at once, leave
  comments (and delete comments it left itself), and save lenses. Takes it adds carry its name. It cannot change
  a word you wrote.
- **Write new** — create notes, books, chapters, tags and versions; file notes into books and chapters; set what
  a book collects; link two notes as versions so Compare pairs them; and add new paragraphs at the end of a note.
- **Edit** — everything you can do at the keyboard on what you shared. On takes: edit, choose, label, lock,
  archive and delete them, and commit or restore a saved moment. On paragraphs: divide, merge, move, insert and
  delete them (deleting a paragraph's only take deletes the paragraph). On notes and books: rename, archive and
  delete notes (deleted notes wait in the Trash for 30 days); rename, finish, archive and delete books; rename,
  move and delete chapters; reorder and take notes out of books. It can also edit, delete and restore any comment,
  and remove tags. When it rewrites a take, the take's words before and after are kept as commits (saved moments),
  so you can always compare and come back.

And a duration: **once** (one act), **until it disconnects**, or **always**. There's also an "open book" switch that
lets every approved client read the whole library; it starts off.

### What always stays yours
- **Your daily Journal, entries made with ⌘J, and anything you mark Private** are never reached by a book or wing
  share. An AI can only reach one of those through a share on that one note, and "always" is never offered for
  them.
- Something an AI can't reach looks to it exactly like something that doesn't exist — it can't tell a private note
  from no note at all.
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
- Draft a revision as a new note and link the two as versions, so Variorum's Compare view pairs them.

A few patterns from the author's own use: design documents where the AI's detail lives in takes beside a readable
summary; language homework where each answer is a take and corrections arrive as new takes; a bilingual book with
the translation in a take behind each paragraph; review of a draft where every suggestion is a take you can accept
by choosing it.

### Seeing what it did, and taking it back
- Every change an AI makes is one undo for you, named after the client (⌥⌘Z). Commits it saves stay, as yours do.
- Each change shows a short receipt with **Open ›** to jump to it, and **Show the AI's Last Change** (⌥⌘O) finds
  the latest.
- The **Activity** tab in Settings ▸ MCP lists what each client did, in words.
- A shared-with-AI icon marks what you've shared wherever it appears — books and gatherings on the Bookcase, notes
  and books in the Library, wings in the wing switcher — and inside a note an indicator says whether it's shared.
  Each says who can reach it and why, with **Change…** and **Revoke**.
- When an AI asks for something it doesn't have, the ask waits quietly for you at the top of Settings ▸ MCP — it
  never interrupts you.

### Privacy, in one paragraph
Your library is one encrypted file on your Mac. AI access is local: the door is a connection on your own machine,
grants live only on that Mac and never sync, and nothing is shared by default. What an AI client then does with
what it reads is up to that client and its provider — share accordingly.

### Learn more inside the app
Variorum's field guide (the book that ships with the app) has a chapter, "AI & the MCP door," that walks through
all of this with the app's own buttons. If it's been deleted, Help ▸ Restore Tutorial… brings it back.

---

## Appendix — the tool names (reference only; the page describes acts, not these names)

As of 2026-10-13. The next MCP update adds a few, and a final list comes with it.
- **Read:** list_books · list_notes · read_note · search · export_note · show_in_app
- **Suggest:** add_take · add_takes · add_comment · add_comments · delete_comment (its own) · save_lens
- **Write new:** create_note · import_document · create_book · create_section · add_note_to_book ·
  file_note_in_chapter · apply_tag · set_book_rule · save_version · link_versions
- **Edit:** edit_take · choose_take · set_take_label · lock_take · unlock_take · archive_take · unarchive_take ·
  delete_take · save_commit · restore_commit · rename_commit · adopt_lens · delete_lens · divide_block ·
  merge_blocks · move_block · delete_block · put_back · set_block_name · set_entry_date · rename_note ·
  archive_note · unarchive_note · delete_note · move_note_to_wing · rename_book · finish_book · reopen_book ·
  archive_book · unarchive_book · delete_book · rename_chapter · move_chapter · delete_chapter ·
  move_note_in_book · remove_note_from_book · edit_comment · restore_comment · remove_tag

---

## Note for Lillian (not for the page)

This version folds in what VX-184 actually built (U1–U5), so it can go to the site agent as one message. It's
written for the public release, which is the next MCP update (VX-246): adding paragraphs to a note (VX-255), the
re-setup rule (VX-258), the Library and wing-switcher icons (VX-268), the pane's tabs and copy button (VX-199,
VX-205), and the updated field-guide chapter (VX-197) land there, before anything public. Your private build from
today doesn't have those yet, and doesn't link the page. One more short update follows when VX-246 is built: its
final pane wording, the final tool list, and anything it changes here.
