<!--
PROVENANCE HEADER — added by the 13c architect, 2026-07-25. Everything
below the horizontal rule is the author's own document, copied VERBATIM
at her instruction ("you can also make a copy of the document with my
verbatim suggestions or save them somewhere") — trimmed for publication
since (see the scope note).

Source: ~/Downloads/Things I want to do before Brazil.md — itself an
EXPORT FROM VARIORUM (the "--- Alternates for this block ---" sections
are the app's own fan-export shape, AppSpec §14's ratified format). The
app produced the document that plans the app.

This file lives in notes/source/ because that directory is history, not
truth (CoreDescription): it is preserved so her exact words survive the
session that read them. The BINDING record of what was decided is
notes/plans/phase-13c-book-forms-and-conversions.md — its "Author
intake, 2026-07-25" ledger (rows A1-A46) dispositions every Variorum
item here with an owning phase.

SCOPE NOTE: the document's personal sections (outside this repo's scope)
were removed from this file for publication, by the author; the marker
line below stands where they were. The Variorum sections that follow it
are her words verbatim. The 13c ledger named above remains the record
that matters.
-->

---

*[personal sections removed by the author for publication]*

Items I want for Variorum:

Some kind of formatting - like bold, italics, different sized fonts, maybe a bit of markdown handling for formatting? markdown has a decent amount of usability but it's also a little annoying. 

I cant use backspace to delete empty blocks with no takes right now which is too annoying - especially when there's an empty block right at the start of the post 

I don’t seem to have the ability to delete / archive empty blocks? 

I want to be able to scroll down into at least a page of empty space so that I can keep the text I'm typing high up on the page rather than being at the bottom of the page. just a slight ergonomics issue.

I really want a variorum mobile app that's quite robust and easy to use 

want a setting for if a newline is automatically a new block as well in takes mode - if it is a new line, shift enter should keep it in the same block. shift enter should also keep it in the same block in write. 

delete several blocks at the same time from a post - highlighting all of the blocks perhaps? block highlight instead of text highlight across blocks? 

DEFINITELY need the ability to have two posts next to each other in the same window. 

ability to save a post as an md file in a particular folder (for the LLM to be able to read it and edit it) and have those edits sync or something 

ability to open an md file and do plain edits in place ? idk would be nice. especially nice if I could open the file by path. 

let’s see how well commits work ig because i’m just copying that block again below the bug is driving me insane. ok nvm it’s just what happens when a block is too long. also dear god i need divide in takes mode.

In addition to the importer, I want something that can save epubs a read only book for you so that I can keep a folder of my epubs for books that I own and fanfictions in a separate area of variorum and read them on my own app on mobile and on laptop - I would also want to add a highlighting element to it and a way to pull comments out and have all of them in a post with the highlighted text too. I'd have to think about how to do this but one (or several) posts linked to an ebook would be super neat and make writing book reviews easier as well. a highlight that auto adds it to a note like "favorite quotes" and automatically adds quotation marks, a dash, the author's name and the book title, would be so nice. I would love to see that

I need some kind of "work with LLM's"  app or micro app that interfaces with Variorum the way the fragments journal bridge does, and that app I can use to open any markdown file (with just the path to it or the name of the file) and see it / make edits / make changes and import it as a post into variorum if I'd like - with sync even? that would be nice. 

the ability to open several variorum windows so that you can edit multiple notes at the same time - or have two separate variorum windows in the same ovearll window, just split in half. 

I need to be able to hit divide on an empty line to include the empty line nowhere and just have a block above and a block below. goodness gracious. 

I need to be able to have a setting where the gap between blocks is a paragraph tall and a setting where a gap between blocks is the height it is right now.

New post in a quicknote format that shows up as like a sticky note floating or something that you can add to and name but you can’t do takes or anything unless you see it as its own post 

Optional: Tabs of open notes underneath “this post” area would be nice for everything you recently have opened  (maybe with like command shift 1 or something like that to go to the first few) 

I need the ability to see a book either by its saved custom order or by an attribute like time to freely change the order of it - should be more like lenses where the order can be saved. 

command shift enter for new block 

command click in take mode to be able to select blocks to merge - should be able to merge multiple if they don't have any takes.

the callouts don't have the spacing on their color right at the moment 

i desperately need a "redo" command to be able to undo my structural undos for when that was an accident

callouts need to be in takes, compare, lenses, etc. and need to have a shortcut item 


infinite verticle scroll editor? bringing you to the right part in takes and then you can go back to the editor / where you were at ? something to think about 

keyboard shortcut for copying all takes together to clipboard, or turning all takes into their own blocks - emerging naturally as a need from how i’m using the app

holy shit, I am so FUCKING happy to be using variorum. it’s literally so beautiful, fits my mind so well, is so fun, and gives me a real feeling of control and like I can genuinely be organized about thoughts and plans the way I want to be, for the first time ever in my whole life. wow. :) (hate that youtube doesn’t allow swearing and i can’t make a video titled “I love my custom notes app so fucking much”. coming from someone with 10k notes on apple notes) 


long into the future: ability to import from markdown and choose whether folders become chapter headings, books, etc. by renaming the folder level or with an interactive tool. to lure people from obsidian

one block being too long is mega tweaking.

warning for destructive actions like undoing a structural edit that created a take - destructive undos should warn. 


maybe different levels of spellchecking

the editor is jumping around when one particular block is longer than the screen and there’s a lot of empty space at the bottom i can’t click into as newlines anymore

ability to reorder takes


in addition to the tabs of open notes at the left, maybe you should be able to star like up to 5 of them so they just always are there on the left. maybe be able to star books? or just individual notes?

need to change the wording from post to note everywhere. 

shortcut for moving a take into being a new block beneath the current block. 

fix this damn whitespace bug that’s happening (scrolling up made it disappear, then typing at the end made it reappear. the full bug is that there will be several paragraphs of empty space but clicking into it, there's nothing there. it disappears on scroll then reappears when you're more on top of it ''



claude mentioned this and it would be a nice improvement to make the color selector available in both modes and the emoji picker could be better too: Confirmed against the current build — yes, you can. It's the callout feature, and it's fully wired end to end (menu → operation → database → render). Here's how and where it stands:

To make one:
1. Be in Write mode (the Write tab, or a book-view inline editor — anywhere a full editor is attached).
2. Put your cursor in the block you want.
3. Block menu → Callout, then choose a color (Blue / Green / Sand / Violet / Rose), and/or Emoji… to attach an emoji. Remove Callout undoes it.

It renders as a soft colored rounded card (with the white-gap spacing) and the emoji in the left gutter, and it shows up consistently on the editor, the read tier, and the book views. The rendering bug I was worried about — the frame not drawing on a freshly-opened editor — was fixed during 13b and is pinned by a test, so that's genuinely closed.

The rough edges as it stands today (works, but minimal):
- One door only — the Block menu. No keyboard shortcut, no right-click item, no ⌘K entry.
- Write-only. In Takes / Lenses / Compare / Canvas / Blocks the menu item is greyed out with the note "Callout frames are set from Write's caret block."
- The color choice is a 5-item menu list, not visual swatches, and those five presets are the whole palette.
- The emoji is a plain text field in a dialog — you type or paste a glyph, or hit Ctrl-Cmd-Space for the macOS emoji panel while that field is focused. There's no dedicated emoji picker.

So the capability is real and works; it's the pickers that are bare-bones. If you'd want nicer swatches, a proper emoji picker, more colors, or a quicker door (shortcut / right-click), that's straightforward polish — say the word and I'll capture it as a design item, but I won't add scope unless you want it.




whew I did not realize how fucking stressed I was about not having a proper notes app to get all my thoughts down in. i’m feeling much less overwhelmed now that all of my thoughts have been quietly collected in here and it felt absolutely amazing to use my app for this, stress and all.



another bug i found: fragments journal did sync and appear, but not in the journal book, just appeared in the pool. the bridge also doesn't seem to refresh often enough.






appending this:

all the messages i sent to that one opus 4.8 session about the changes i want 


❯ the progress indicator bar seems to be a bit buggy so I think that we should just fully remove it for now and I'll adit later if I feel inclined towards that. and yeah, Book is basically like pages but with two posts side by side. it is new compared to what we have right now though. for read's paginated mode - two page spread. in book spread: flipping should advance two posts at once (turn the leaf) BUT you should have the option to move it just one page if you specially select that (maybe like a half arrow button or something), in case the turn the leaf cuts you off from seeing two posts side by side.)

❯ ok I think the issue is that the book view does not look how I expected it to look because I want to be able to see pages side by side  [Image #2]. also, the horizontal scroll bar needs to be gone from the Book page. I'd also change Book -> Outline, Pages -> Book, and Read can stay as read.  I wanted it to look this: [Image #1] but each page is a post you can scroll up and down vertically within.


and random q&a about how LLM workable the project is (unverified claims, should NOT be treated as the absolute truth)

hi claude, I wanted to ask a question about how easy my variorum project is to work with an LLM with. I'm wondering if I could get variorum to work in a particular folder, like obsidian, and how different that is from our current solution. or is that not different from our current solution? are all of my text files .md files or is that just for export? and after export, I don't currently have any way to reimport right?

Great question, and it gets right at a real fork in the design. Let me take your questions in order — the short version is that the Obsidian idea is much more different from what you have than it might feel, but you're actually in better shape on the LLM-legibility and reimport fronts than you think.

Could Variorum work in a folder, like Obsidian? Is that different from the current solution?

Yes — and it's different at the foundation, not at the config level. Obsidian's model is "one note = one .md file, the folder is the database, plain text is the truth." That is precisely the documents-as-text-blobs model your design explicitly rejected (OverallModel §8, "Why not documents-as-text-blobs"). Variorum's whole spine is that a block has permanent identity maintained live during editing and never recovered by diffing text. A folder of markdown can't hold:

- variants / the fan (many alternate texts for one block)
- per-variant commit history
- lineage edges (derived_from / version_of)
- the pointer religion (divide/merge/extract as reversible pointer moves)
- the DB-enforced invariants (single ownership, etc.)

To keep those in a folder you'd have to invent a sidecar format next to every .md — at which point you've rebuilt a database in files, minus the constraints SQLite hands you for free. So "make it an Obsidian vault" isn't a setting; it's adopting the alternative you already ruled out.

But I suspect the real question under this is "how LLM-workable is my store?" — and there the answer is better than "folder of markdown" implies. Your SQLite file is a single plain file with a fully documented schema (rows-as-truth). An LLM can open it, query it, and read every block/variant/commit/edge directly — arguably more legible to a tool than a pile of loose markdown, because the structure is explicit instead of inferred. The one rule is it shouldn't write raw rows — that bypasses the operations API and can break invariants I1–I10. Reads are free; writes want to go through Operations.

Are all my text files .md, or is that just for export?

Neither, really — you don't have text files at all. Your prose lives as rows: variant.working_text (the one mutable field in the whole system) plus commit_point.text snapshots, inside the one SQLite store. Markdown shows up in exactly two places:

- as the export serialization (Phase 11b), and
- as content — if you type a markdown heading, that's just text sitting in a block (AppSpec §14 item 8; there's no schema column for it).

There is no .md-file-per-note anywhere in the real store. The markdown folder only exists the instant you hit export.

After export, do I have any way to reimport?

You actually do — it shipped, so this is the one place your memory is off. Phase 11b (2026-07-16) added markdown/text import: importPost / importBlocks, drag-drop doors (sidebar → library, a pool row → scraps in that pool), and a File-menu panel. It even round-trips at the byte level (export → import → export is byte-stable, pinned in the closeout).

The caveat worth holding onto: import is a fresh mint, not a merge. It brings the text back in as new posts/blocks; it does not reconstruct fans, commits, or lineage (export already flattened those to "chosen text + labeled Alternates" sections), and it doesn't flow edits back into the same existing blocks preserving their identity — it creates new ones.

---
One thing worth naming, since your framing was LLM-workability: if what you'd really want someday is "an outside surface — Obsidian, or an LLM working in a folder — edits my prose and the edits land back without losing block identity," you've already built that pattern. It's the Fragments bridge: an external co-writer projection surface, edits keyed by a stable key (entry_date), landed through ordinary operations with conflict-as-variant protection so nothing gets clobbered. An "Obsidian-folder bridge" or "LLM-workspace bridge" would be the same shape pointed at a folder instead of Fragments' journal_entries table — real work, but a proven pattern, not new architecture.

Want me to sketch what a folder/LLM co-writer bridge would actually take, or is this orientation enough for now?
