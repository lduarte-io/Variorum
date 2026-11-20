# Variorum 1.5

This update makes two things say exactly what is true. Search no longer comes back empty because of a stray symbol or a dash, and it gained a check-and-rebuild for its index and a search of its own inside the Trash. And your daily Journal — which has always been kept from AI — now shows as Private everywhere the Private mark appears. Around those sits a round of care for connected AI tools: steadier connections and status lines that count only what still stands.

- Your daily Journal and every entry in it now wear the Private mark — on the Bookcase, in the Library, in the Book Panel and on the note itself — and the Private row in its Book Settings and in an entry's menu reads ticked and locked, with a line saying why.
- A symbol beside real words no longer empties a search: `red +` finds what `red` finds.
- A dash or other punctuation beside a tag now answers what the tag answers — in the Library, a book's search, ⌘K, the counts and the tag suggestions — and a search holding only punctuation says why it found nothing.
- Settings ▸ Data Safety has a new Search index section: Check Index compares the index with your notes and changes nothing, Rebuild Index rebuilds it from your notes, and each says what state the index is in afterwards.
- The Trash can search itself: "Search the Trash…" finds deleted things by name or by their text, and shows the words around a match under the row.

## For connected AI tools

- A tool can remove a version link between two notes only when it may edit both of them; permission to write new notes is no longer enough.
- Linking or unlinking two notes with long titles now says what happened in the status line — "unlinked two notes as versions" — instead of "made a change".
- The count in a tool's status line no longer includes changes you have undone.
- If a note a tool is showing you is deleted in that instant, Variorum says it's gone instead of opening an empty page, and ⌥⌘O stops pointing at a change whose note is gone.
- If the activity log can't record a tool's request to show you something, the tool still hears the true answer and you get one notice that the log missed it.
- A tool that stops reading can no longer delay other tools' updates or hold up unlocking your library.
- Tools hear that their tool list changed only once they have finished connecting.
- Starting the MCP server twice in quick succession can no longer leave it unreachable or wrongly say it couldn't start.
- The field guide's AI chapter now lists unlinking versions under the Edit permission; Help ▸ Restore Field Guide… brings the updated chapter into an existing library.
