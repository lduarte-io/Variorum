# Variorum 1.5

Bug fixes for search and the daily Journal, a search field in the Trash, and fixes for connected AI tools.

## Fixed

- Search had a bug where a symbol next to a word made the results come back blank. Fixed: `red +` now finds the same notes as `red`.
- Search had a bug where a dash or other punctuation next to a tag left out most of the tag's results. Fixed: `— #flora` now finds everything `#flora` finds.
- A search made only of punctuation used to say "Nothing matches." It now explains that search looks for words and numbers.
- The daily Journal had a bug where it and its entries didn't show the Private mark, and Private wasn't ticked in the Journal's Book Settings. Fixed: both show the mark, and the Private row is ticked and locked with a line saying the Journal is always Private.

## New

- The Trash has its own search field. It finds deleted things by name or by their text and shows the words around the match.
- Settings ▸ Data Safety has a Search index section. Check Index compares the search index with your notes and changes nothing. Rebuild Index rebuilds it from your notes.

## For connected AI tools

- Removing a version link between two notes now needs the Edit permission on both notes. Permission to write new notes used to be enough.
- When a tool linked or unlinked two notes with long titles, the status line only said "made a change". It now says "linked two notes as versions" or "unlinked two notes as versions".
- The status line's count of a tool's changes included changes you had undone. Fixed.
- If a note was deleted at the moment a tool was showing it to you, an empty page opened. Variorum now says the note is gone.
- If the activity log can't record a tool's request to show you something, the tool still gets the correct answer and you get one notice about the log.
- A tool that stopped responding could delay other tools or hold up unlocking your library. Fixed.
- Tools were sometimes told their tool list had changed before they had finished connecting. Fixed.
- Turning the MCP server off and on quickly could leave it unreachable, or make it wrongly say it couldn't start. Fixed.
- The field guide's AI chapter now lists unlinking versions under the Edit permission. Help ▸ Restore Field Guide… brings the updated chapter into an existing library.
