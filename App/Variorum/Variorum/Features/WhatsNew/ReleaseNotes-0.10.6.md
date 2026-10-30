# Variorum 0.10.6

## The editor holds its ground

- An edit arriving from outside the pane you're writing in — an AI client, another window, a restore — now ends your live session there cleanly instead of being overwritten by your next keystroke.
- Undo in Write now lives and dies with the editor: leaving the mode can't strand undo steps that reach a torn-down view.
- Restoring a commit from its read-in-full sheet now lands in the note exactly as the row's restore does, from the inspector too.

## Books carry your place

- Opening Read ▸ Pages lands on the page you were at, never page one.
- Index → Outline now lands with your block itself on the page, not just its note's row.
- Leaving Read ▸ Scroll carries the story on your screen, not the note you last edited.
- A landing the page can't fully reach settles at once instead of holding.
- The Index's carried place can no longer go stale.

## The AI door asks first

- show_in_app lands as an offer: the client asks, and you open it with one press — or set the dial in Settings ▸ MCP to move at once or never.
- An ask arriving while you're away always asks, under every dial but never.
- A client can now show you a saved version of a note.
- Pressing an ask or an AI receipt whose place is gone says so and opens nothing.

## Smaller touches

- The ⌘/ shortcuts helper is rebuilt: search, grouped headings, and descriptions in your library's voice.
- An unnamed commit's row now rests on its first words.
