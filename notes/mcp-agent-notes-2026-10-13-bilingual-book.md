# MCP door — agent notes from the bilingual book build (2026-10-13)

From the Claude Code session that built **o ladrão de raios** through the door: 25 notes (dedication, contents, 22 chapters, acknowledgments), 3,843 paragraph blocks of Portuguese plus the English as a take labelled "english", and two lenses on every note ("português", "english"). Every block and every lens was verified against the source files. It is the largest single job the door has carried so far.

Each suggestion below says which kind it is, per your 2026-10-11 framing: **(a)** a human action the door is missing, or **(b)** agent ergonomics, justified by what it cost in this run.

## How the run went

- **Scale:** about 150 MCP calls over roughly two hours, using a book-scoped "always" grant.
- **Refusals:** none.
- **Disconnects:** one, on your side; nothing was half-written.
- **Payload size:** `create_note` took whole chapters in one call, up to 253 blocks and 64,000 characters. Every curly quote, em dash and embedded newline round-tripped exactly.
- **The hidden cost was copying, not the door.** A model has to regenerate every character it sends:
  - About 185,000 words of text, retyped into `create_note`.
  - About 7,700 take IDs, retyped into `save_lens`.
  - About 2.6 million subagent tokens for the writing step alone.
  - The read-back check caught exactly one transcription slip ("beliscáu" for "beliscou", in chapter 11). It was fixed with `edit_take`. Without a read-back, that slip would have shipped silently.
- **Every chapter's `read_note with_ids` was 100,000–133,000 characters.** That is over Claude Code's tool-output cap, so the reply landed in a file on disk. Verification only worked because a script could read that file and this session's transcript. An agent without a filesystem could not have checked its own work.

## Suggestions, most valuable first

1. **`create_note` (and `import_document`) should return take IDs, not just block IDs.** (b)
   - Per block: the shown take's ID plus each extra take's ID and label, in order. `add_take` already returns its `take_id`, so this would make the two consistent.
   - Cost today: one full `read_note with_ids` per note just to learn IDs that the write itself minted. That came to 25 reads and about 2.7 million characters in this run.

2. **`save_lens` by label: "every block's take labelled X".** (b)
   - Shape: `save_lens(note_id, name, label: "english")`, with `label: "chosen"` (or `"shown"`) to pin the current chosen takes. A block with no take of that label falls back to its chosen take, as lenses already do.
   - That's what a language lens actually is: one label throughout the note. Today it's spelled as 200 UUIDs.
   - Cost today: about 7,700 UUIDs copied by models for this book. An ID list is also a classic place for an off-by-one mistake. It didn't happen here, but only because a script re-checked every pick.

3. **A content digest on write replies, for verification without a read-back.** (b)
   - Return a short hash of each take's stored text (or one digest per note) from `create_note`, `import_document` and `edit_take`.
   - The agent compares it locally, and byte-exactness is proven without pulling 130,000 characters back through the wire.
   - The one slip this run caught is the argument: retyping at this scale will make an occasional error, and a cheap check matters.

4. **Insert blocks into an existing note.** (a) and (b)
   - Shape: `insert_blocks(note_id, after_block_id?, blocks)`, with the same block shape as `create_note`.
   - **(a):** a human can type new blocks anywhere in a note; an agent can only create whole notes or divide existing blocks.
   - **(b):** large documents could be written in chunks, so a mid-write disconnect costs a chunk rather than a chapter. Late fixes would also be direct. For example, the chapter-16 gap I translated in had to be fixed in the files before writing, because adding four blocks afterwards would have meant a chain of divides.

5. **An idempotency token on creating calls.** (b)
   - Shape: `create_note(..., client_token)`. A retry with the same token returns the first result instead of minting a second note.
   - The disconnect we hit came between chapters, which was luck. If it had come mid-call, the agent couldn't know whether the chapter had landed, short of matching titles in `list_notes`.

6. **Compact or paged `read_note`.** (b)
   - VX-186 (dropping the duplicated shown text) helps, but a big chapter would still be around 65,000 characters.
   - Either an IDs-only form (`with_ids: "ids"`: block, take and label IDs, no text) or block-range paging would let any client read a big note in pieces.

7. **Already planned, and this run confirms the need: VX-195 and VX-196.**
   - Deleting a note, taking a note out of a book, deleting and renaming chapters, and renaming a note.
   - You cleared the old test notes and chapters by hand because the door couldn't.

8. **A bulk road worth considering: lenses on import.** (b, with a format angle)
   - The Variorum document format plus the Bookcase folder drop could have carried all of this text with zero model retyping: I generate a folder of chapter files, you drag it in, and a book appears.
   - The only thing the door added that import can't is the lenses.
   - An import option (or a header line in the format) for "one lens per take label" would make parallel-text and bilingual builds a two-minute human act, with the door reserved for judgment work.

9. **Small documentation inconsistency.**
   - `add_take`'s description says a take is "labeled with this client's name (plus your label)".
   - Takes created through `create_note` stored my label exactly ("english"), with no client name.
   - Either behaviour is fine; the two descriptions should say which applies.

10. **Minor: `create_note` could take a `section_id`.** It would file the note in a chapter in the same call. I didn't need it, because the book ended up as one note per chapter.

## What worked especially well (keep these)

- **Big writes just work.** 64,000-character `create_note` calls went through cleanly, with exact Unicode throughout.
- **Lens reads are easy to check.** Each lens's `picks` plus `dangling_picks` made lens verification mechanical. That field is a gift to agents.
- **Grants were frictionless.** "Always" on a single book was exactly the right scope for a multi-hour run. Reconnecting restored the tools and the standing grant immediately, with no re-approval.
- **The undo model is calm.** One undo per note, named after the client, and `edit_take`'s before/after commits made the one correction fully traceable in the note's history.
- **No surprises.** Zero refusals. The instructions' "ids are live" warning and the format notes were accurate.

## Not Variorum's, but worth knowing

- **Claude Code saves oversized MCP replies to a file instead of showing them.** That's what made script-based verification possible.
- **Claude Code's auto-mode safety check blocked a local script from reusing this session's MCP key**, which I'd proposed as the exact-text write road. That's correct behaviour on Claude Code's side.
- **The honest road for scripted bulk work is a separate client setup:** its own name and key, approved and granted by you, which the per-setup key design already supports. A short "automation / script" entry in the pane's setup menu, with a minimal example, might make that road obvious. This is only worth doing if bulk jobs like this become common.

If you want tickets, I'd group them as:
- Lens ergonomics for agents: items 1 and 2.
- Write verification: item 3.
- Insert blocks: item 4.
- Idempotent creates: item 5.
- Compact `read_note`: item 6, possibly folded into VX-186.
- Lenses on import: item 8.

Item 9 is a one-line documentation fix for VX-197's truth pass.
