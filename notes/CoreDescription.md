# Variorum — Core Description (Vision)

*A variorum is an edition of a text that preserves its variant readings. That is this app.*

This document is the **why** — the product vision and the author's requirements, in her terms. It should change rarely. The technical shape lives in `OverallModel.md`; the buildable detail lives in `AppSpec.md`.

---

## What it is

A native, premium Apple writing tool. The primary user is the author ("and whoever else has a brain just like mine"). It must serve three modes over **one** model:

- **Daily journaling** — simple; typically one entry = one block; ordering usually by the day written.
- **Blog posts** — many ideas; pull sources and notes to the side; try out alternate paragraphs.
- **Books** — chapter/scale ordering matters most; same paragraph/word/sentence-level editing as blog posts.

The design identity: **find the atomic unit, then build around it.** The unit is the **block**. Nothing owns blocks; everything points at them; every view is a different traversal of the same store. Same non-destructive, pointer-based religion as ClipFarm (video), applied to prose.

## The core feeling

- **Free and dynamic to work with — ideas are never stifled.** Not forensic reconstruction; just keeping choices open as long as wanted.
- **Snappy, always.** Apple Notes lags for seconds past ~10k words in a note; this app must never have that failure mode. Performance is a hard constraint, not a nice-to-have (see AppSpec §4).
- If it's beautiful, bug-free, fast, interesting, and flexible, complexity is acceptable. **This is NOT Pages.**
- Calm default, depth on demand: at rest a document is seamless minimalist prose; the variant machinery is summoned per-block, on request. Complexity lives in the store; restraint lives in the UI.

## What it is not

- **Not a knowledge base.** No transclusion, no shared blocks across posts — that brings management problems the author explicitly rejects. Reuse is copy + lineage edge.
- **Not Pages / not Apple Notes.** Not a generic word processor, not a thousand-notes-click-each-one app.
- **Not collaborative.** No real-time collaborative editing, ever envisioned.
- **Not forensic.** No word-level change tracking anywhere. The system preserves choices and lineage — a family tree, not a court record.

## The pillars (requirements essence)

1. **Blocks with variants ("the fan").** A block is a stored node with permanent identity. It's cheap to fan out many parallel candidate texts for a block — ten versions of a paragraph if wanted — held open side by side, not auto-closed. Each variant has its own little commit history. The floor is a sentence (or a single word), the default a paragraph, the ceiling unbounded (multi-paragraph blocks are important) — **and a block is always its own paragraph on the surface** (block boundaries render as paragraph breaks; no sub-paragraph seams exist; making a block of a sentence promotes it to its own paragraph — R26/R33, describing shipped behavior).

2. **Autosave + deliberate commits, lock orthogonal to both.** Always autosaving; a deliberate "save this version" shortcut appends an immutable savepoint. Lock is a reversible guard, never a snapshot. Posts can be marked complete (and un-marked).

3. **Structure via pointers and tags, never containment.** Posts are ordered pointer lists over blocks. Books are "readings" — **curated ordered books AND smart (tag/query) books, both saved to the shelf** — and **chapters are real, reorderable groupings within a book** (`reading_section` rows a membership points at — still pointers, never containment). *The original "a chapter is effectively a tag section" line is reversed (R28); smart readings keep tag-derived sectioning.* Hierarchical tags, applied to posts and (cheaply) to blocks. *(Ratified additions, built at Phase 13i: **wings** — multiple in-store libraries, a level above books, "a different room in the same house"; the default wing **Home** is undeletable and holds quick notes, the daily Journal book, and the tutorial. And the **opt-in Owned book**, which deliberately bends the notes-in-many-books default for books that want real ownership — her words: "right now the 'Book' concept is just a bit too weak for it to feel useable, so notes will have to lose a little ground to let books be stronger." Both remain pointers underneath; the design record is `notes/plans/phase-13i-smart-book-identity-brief.md`.)*

4. **The split taxonomy.** Extract (source survives; chop a boundary span off painlessly), Divide (source consumed; single-variant is the trivial everyday case; multi-variant is the one deliberate ceremony, with W resolution: the original is preserved whole), Merge (mints fresh, mirrors Divide-W). All reversible pointer moves, never destructive rewrites.

5. **Many views over one store.** Continuous book view, book-scrub (page = a post; 50 entries = 50 pages even if one is 10k words), infinite scroll, timeline, side-by-side (`text | v1 | v2 | text`), swap-and-reread, outline-left/draft-right with derived-from mapping, diff (whitespace optional), folder, canvas/sticky-notes, expand-all-fans. Multiple views is *the point* — each stress-tests a different edge of the model.

6. **The inspiration pool.** A holding area of scattered notes and loose sentences; drag pieces into a draft (copy + lineage, never shared ownership).

7. **Sane sorting.** Sort by when 80%+ of something was edited. Fixing one typo must never reshuffle the library.

8. **Mobile as a smaller surface — but a real one.** Add journal entries and edit existing blocks' active text from iOS. Journal restrictions are a UI profile, never a separate data model — an entry can graduate to a full post with zero migration. *Ratified supersessions (the binding record is the gate-sitting section of `notes/plans/mobile-app-plan.md`): the original "no variant/fan gestures there" line is superseded — **takes ARE included on mobile** (R58) — and the interim "smaller than the Mac" framing is superseded in its turn: **mobile is a complete, comprehensive app** ("it should feel basically just as capable as the mac app"), her daily-driver complementary app ("like apple notes on the phone v. computer") that "can't be a very lobotomized version without me missing functionality." Named exceptions, hers: Compare, snippets, and the sticky-note style of editing are not replicated; the ceremonies need no mobile replication — a simpler workaround default stands in (her divide precedent, which then became the Mac's own default), and lens-style surfaces may compromise in shape while keeping the capability. Mobile is its own separately-planned project rather than a numbered phase.*

9. **Commercial someday.** Architecture must stay fast as complexity scales, and the schema is shaped now for a future row-based sync engine and multi-tenant accounts — designed-for now, built later.

## Source material

The full authoritative history lives in `notes/source/`: `REQUIREMENTS.md` (the author's wishes verbatim), `TECHNICAL_DECISIONS.md` (settled commitments with the why-nots), `SPEC.md` (the original holistic spec this project's AppSpec evolved from), `HANDOFF(1).md` (design rationale), the original chat transcript PDF, and **`author-intake-2026-07-25.md`** — her first intake written *from real daily use*, preserved verbatim at her instruction and notable for being an **export from Variorum itself** (the fan-export "Alternates" sections are the app's own format). Its Variorum items are dispositioned row-by-row in `notes/plans/phase-13c-book-forms-and-conversions.md`'s intake ledger.
