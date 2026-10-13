# Brief for the stargazing.tech agent — the Variorum MCP guide page (2026-10-12)

**What to build:** one public page at **`https://stargazing.tech/variorum/mcp`** — exactly this path. Variorum's
app tells every connected AI to read it, so the URL is load-bearing: if the site's structure can't host this exact
path, tell Lillian before choosing another, because the app's text has to change with it. The page must be live
before the Variorum build that links it ships (launch, 2026-10-13).

**Who reads it:** two audiences at once — a person setting up an AI with Variorum, and the AI itself (an AI client
may fetch this page to learn what it can do). So: plain, scannable HTML; real headings; the facts in sentences, not
only in images; no content hidden behind tabs or scripts an AI fetcher wouldn't run.

**Voice:** calm, professional, clear — the voice of Variorum's own field guide. Sentence case everywhere (headings
included); never capitalize a word for emphasis; no marketing superlatives; no stacked dashes and asides; it should
not read as AI-written. Short paragraphs. Match the existing Variorum pages' styling on the site.

**Fact discipline:** everything below is true of the build shipping at launch. Don't add claims beyond it. Where
this brief says something is the author's alone, keep that framing — it's a design decision, not a missing feature.

---

## Page content (the facts, in a suggested order — write it in your own page voice)

### What this is
Variorum is a writing app for the Mac. It has a door for AI: a local MCP server (Model Context Protocol, the
standard way AI tools connect to apps). Any MCP client can use it — Claude Code, Codex, or any client that runs a
standard MCP stdio server. The door is closed until you open it, it only works while Variorum is open on your Mac,
and it reaches nothing until you share something. The phone app has no door.

### Setting it up
1. In Variorum, open **Settings ▸ MCP** and turn on **Enable the MCP server**.
2. Under **Connect a client**, choose your client (Claude Code, Codex, or any MCP client) and press **Copy setup
   command**. Run what you copied (for Claude Code, in a terminal), then start a new session of your client.
3. The first time the client connects, it appears in Settings ▸ MCP as a connection request. Approving it admits
   the client with no access yet — you then share what you want it to reach.

Each copied setup carries its own key, which ties the client's name to that setup; a connection under that name
without the key is refused. If you set a client up again (a new computer setup, a reinstall), just copy and run
the setup command again: the new setup replaces the old one, and the client keeps everything you shared with it. Be clear about the limit, as the app is: this tells two tools apart, but it isn't a
defense against other programs running as you on your own Mac.

### What you can share, and for how long
You share a **note**, a **book** (including notes added to it later), or a whole **wing** (Variorum's word for a
separate library). Each share has a level, and each level includes the ones before it:
- **Read** — read and search.
- **Suggest** — add alternative versions ("takes") beside your text, leave comments, save lenses. It cannot touch a
  word you wrote.
- **Write new** — create notes, books, chapters, tags and versions; file notes into books; set what a book
  collects.
- **Edit** — everything you can do at the keyboard on what you shared: edit, choose and commit takes; divide,
  merge, move and delete paragraphs; and arrange and manage notes and books. Every edit is bracketed by automatic
  commits (saved moments) before and after.

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
- Create books and chapters, and file notes into them.
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
- A shared-with-AI icon marks shared books (and gatherings an AI can read through a wing share), and notes show
  whether they're shared; each says who can reach it and why, with **Change…** and **Revoke**.
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

## Note for Lillian

A short delta may follow tomorrow morning: the overnight run (VX-184) writes one at the end of this file if
anything it built changes a fact above, plus the final list of tool names. Carry that delta to the site agent if
it appears; otherwise the page as built from this brief is correct.
