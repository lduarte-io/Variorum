# VX-633 — the bilingual Prince seed book

**STATUS: BUILDING (kicked off 2026-10-28 at her Air sitting, /architect-phase; branch `vx-633-prince-book`, the Air's one clone). The build lands the BOOK; at her word the Pro's umbrella run absorbs VX-633 for review/release integration — her ruling at kickoff: "once we have the prince minted, I actually will have that run absorb this ticket and making sure it's part of a release and such… handle the part where you actually make the book, and give me a prompt to carry over to that pro session when the book has been pushed."**

The 13b constitution (P-1…P-9, `.claude/skills/architect-phase/SKILL.md`) binds by reference; this effort is seed content + seeder integration, no new surfaces, no `Sync/` (the VX-669/678 umbrella on the Pro holds that slot; this effort deliberately does NOT touch `SyncSession.configure`, the dedupe facts seam, or anything in `Sources/VariorumCore/Sync/` — the Prince joins `Book.all` with `joinsPristineDedupe: false`, so the engine's facts list stays byte-identical).

## Her rulings (2026-10-28 kickoff, verbatim-faithful)

- **R-633-1 — scope:** "let's do the full book, all bilingual." Dedication + all 26 chapters; every paragraph block carries Marriott (chosen) + the Italian original (second take, unchosen).
- **R-633-2 — process shape:** the Pro is running the umbrella tickets now; "if you want to leave certain parts of it undone because it's touching the same areas of code & you want to just handle the part where you actually make the book, and give me a prompt to carry over to that pro session when the book has been pushed, that is a fine solution."
- **R-633-3 — naming:** book name **"the prince"**; the Italian take's label **"il principe 1532"** — "so basically what you recommended, but the title in both and just the title changes to italian."
- **R-633-4 — third takes:** "i'd make a few of the most famous lines have 3 takes (the what's better, loved or feared, the lion and the fox, etc. you can have some discretion on what constitutes famous / quoted enough, but i think it would be cool for the standout lines)." Source: Luigi Ricci's PD translation (Gutenberg #57037 — Thomson is not on Gutenberg).
- **R-633-5 — chapters/parts:** notes are chapters; the book's `reading_section` rows are the FOUR PARTS, her two candidate name-sets (the seed uses the second/latest, lowercased to the shelf idiom; she may retitle at the edit pass — chapter renames are free):
  1. first set: "The Geography of Power" (1–11) · "The Tools of Power" (12–14) · "The Psychology of Power" (15–23) · "The Goal of Power" (24–26);
  2. second set (her follow-up, SEEDED): "Types of Principalities (Chapters 1–11), Military and Armies (Chapters 12–14), Rulership, Conduct, and Virtue (Chapters 15–23), The State of Italy and Conclusion (Chapters 24–26)".
- **R-633-6 — defaults confirmed:** book clock 1532; front note "about this text" DRAFTED by the architect, her edit pass IN THIS SESSION ("yes, draft it, give it to me for an edit pass and i'll do the edit pass here"); seeded owned; tagged (own tag + #classics); Welcome shelf; classics gathering; restore door; "sherlock and jekyll and hyde are still restorable" (launchSet = [.prince]; sherlock joins jekyll as restore-only; `Book.all` keeps every door).
- **R-633-7 — the two-copies disclaimer:** "i don't know if it needs the two-copies disclaimer based on what the umbrella is building, get back to me on that." ANSWER OWED → see Open items. (Analysis: the umbrella removes the dedupe's DEFENSE leg, not the pass; the Prince sits OUTSIDE the pristine dedupe because a born-fanned copy always classifies EDITED — so two devices seeding before their first sync still mint two Prince books, both kept; post-umbrella the deliberate delete of the spare STICKS. A one-line takemania-style disclaimer stays warranted, softened to "delete whichever copy you don't want.")
- **R-633-8 — tutorial/tour sweep:** NOT this effort. "there is a ticket for updating the onboarding / tutorial [VX-292], you can add the instructions that are needed to that ticket that i will have to run soon after the sweep, i will do that ticket once this has merged and the release with the prince instead of sherlock being the default is live."

## Sources

- English (chosen takes): W. K. Marriott 1908, Gutenberg #1232 (fetched; UTF-8; `*** START/END` boilerplate at lines 29/4829; headings `CHAPTER <ROMAN>.`, one `[n]` footnote marker class; DEDICATION present; appendix material after XXVI to drop).
- Third-take lines: Luigi Ricci, Gutenberg #57037 (fetched; headings `CHAPTER <ROMAN>` no period; much coarser paragraphs — used ONLY for the famous lines).
- Italian (second takes): NOT on Gutenberg. The PD text lives on Italian Wikisource ("Il Principe", 1532 — PD everywhere). Fetch from it.wikisource.org; record the edition page and source URL here when landed.
- Raw downloads live in the session scratchpad until curated; the repo lands `notes/source/prince-*.txt` originals + `notes/source/prince-extract.py` (the jekyll-extract/sherlock-extract precedent) + the bundled resources.

## Design (the architect's, within rulings)

- **Resource format:** TWO parallel bundled resources, `ThePrince.txt` (EN, exactly Sherlock's `%%% <title>` format) and `ThePrinceItaliano.txt` (same `%%%` titles, paragraphs aligned 1:1 with the EN file). The existing `parse` reads both; pairing is by title + paragraph index. The extract script ENFORCES per-note paragraph-count equality and the build's seed-shape test pins it (a drifted pair fails the suite, never seeds misaligned).
- **Alignment:** Marriott's paragraphing leads; the Italian text is re-paragraphed to match, curated chapter by chapter (the Italian source's own breaks are coarser). The extract script holds the curated alignment; mismatches it cannot resolve are listed for hand fixing before the resource lands.
- **Seeding road:** `Book.prince` entry (clock 1532, `profile: "book"`, `joinsPristineDedupe: false`, own tag + classics, owned at seed — Sherlock's U7 arrangement precedent); `place` imports the EN note, then a Prince-specific post-import pass walks the minted blocks in placement order and attaches the Italian take per block (`newBlankVariant` + `autosave` + `setTakeLabel("il principe 1532")`, never chosen — the Takemania ops road, under the book's clock), plus the Ricci third take on the famous-line blocks from a small table in `SampleLibraryPrinceBook.swift` keyed (note title, paragraph index).
- **Famous-lines candidates (architect's discretion per R-633-4; final set recorded at build):** XVII loved-vs-feared ("it is much safer to be feared than loved…"); XVIII the lion and the fox; XVIII men judge by appearances; XV the "how we live / how we ought to live" pivot; XXV fortune-as-river / fortune-favors-the-bold; VI the innovator's peril ("nothing more difficult… than to take the lead in the introduction of a new order of things"). Aim ~4–6 blocks.
- **The front note:** "about this text" in the front-matter section — provenance (Marriott 1908, the 1532 Italian, Ricci on the standout lines), how to open a fan, the softened two-copies line (pending R-633-7's answer), lowercase sentence case throughout. Drafted for her edit pass in-session.
- **What this effort deliberately does NOT touch (the umbrella's or later):** `Sources/VariorumCore/Sync/` and the dedupe-facts wiring; the tutorial/tour copy (VX-292 instructions appended instead); the website demo captures (the launch-plan's road 1 — the demo wants the seeded note AFTER this merges); release machinery.

## Acceptance units

- **U1 — the content:** curated, aligned bilingual resources + extract script + famous-lines table; evidence: the script's alignment report clean, spot reads of EN↔IT pairing on sample chapters (I, VI, XVIII, XXV, dedication).
- **U2 — the seeder:** `Book.prince` + the bilingual post-import pass + launchSet swap + restore door + pins (seed-shape test: counts, parts, labels, owned, clock; the resource-pair equality pin; existing suites for the swap); evidence: headless `swift test` + a Debug-store seed walkthrough read.
- **U3 — the hand-over:** the front-note edit pass (hers, this session); VX-292 instruction append; the Pro carry-over prompt (review scope, release integration, the canon deltas owed at ITS closeout: SurfaceContracts seed-set line, AppSpecRecord entry).

## Open items / ledger

1. R-633-7 disclaimer — answer delivered to her, her word pending. → OPEN
2. Italian source fetch (Wikisource) + edition record. → IN FLIGHT
3. Front-note draft → her edit pass. → OWED
4. VX-292 instruction append (after the build's sherlock-reference grep). → OWED
5. The Pro carry-over prompt. → OWED (last)
