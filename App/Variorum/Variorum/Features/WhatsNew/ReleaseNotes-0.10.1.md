## Turning on sync now finishes the job

The first sync runs the moment you turn sync on, and the window stays to confirm it landed — or to say exactly what's in the way. Before this fix, a newly set-up library could sit saying "Sync locked" until the next launch, looking done while nothing had ever synced.

- A library that hasn't joined your account now says "Sync isn't on for this library yet" instead of reading as locked — and when your account already syncs, the door says "Sync this library…" instead of "Turn on sync…".
- In Castle with "Always ask", typing your passphrase or twelve words at the lock screen now unlocks sync for the session too. Before, sync stayed locked after every lock until a key change.
- After your library joins an account, the card offering to record new twelve words goes away — the words you hold are the account's, and pressing the card would have replaced them.
- Settings ▸ Protection gains "Check my passphrase or twelve words…" — type either one to check it. Checking changes nothing.
- Standard libraries no longer raise stray Touch ID prompts left behind by an earlier Castle library on the same Mac, and those leftovers are now cleaned up properly.
- The lock screen's "Use your twelve words instead" now opens from the words themselves, not just the little arrow.
