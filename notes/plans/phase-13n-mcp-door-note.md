# Phase 13n — The MCP door (DESIGN NOTE)

**Status: DESIGN NOTE ONLY — created 2026-08-19, the same author
conversation that created the master-plan row.** This is the 13h
design-note pattern applied to 13n: her verbatim vision and use cases,
preserved for the kickoff sitting, binding nothing beyond the words
*[removed for publication]*
§9 (the 2026-07-30 inclination — MCP server projected from the capability
registry, insure-first writes, consent-scoped reads, local LLMs
first-class) and the master plan's 13n row.

## The dream vision (author, 2026-08-19, verbatim)

> "my dream vision is that per note even, people are able to allow their
> desired agent to work with variorum (I need to be able to use claude
> code with it) and you can limit it so that your AI can't edit your
> takes, could only make new takes and save a lens with the AI takes to
> view (which would be good for reviewing work for example), all the way
> to full permissions."

**Claude Code is the must-work first client.**

## Her use cases (same conversation, verbatim)

> "I think that variorum has so much potential in this space - there's a
> lot of writers who want all their writing fact checked but don't want
> it clobbered by AI and there's basically no option for such a nice side
> by side look that I know of that's also a full editor. And it could
> even be useful for like 'i'll complete this portuguese worksheet, then
> you grade it as a new column of takes'. I could even see it being
> allowed whole book access so it could add tags, a new lesson, build the
> lessons for you, you complete them, then it's graded, etc. there's so
> much potential in this idea"

Named shapes inside that, pulled out so the sitting can address each:

1. **The fact-check reviewer (the market gap she names).** Writers who
   want their work fact-checked without AI clobbering it — the AI's
   findings arrive as new takes beside the text, in a side-by-side
   surface that is *also a full editor*. She knows of basically no
   existing option with that combination.
2. **The graded worksheet.** "I'll complete this portuguese worksheet,
   then you grade it as a new column of takes" — human writes, AI grades,
   the grades land as a take column. Reads naturally as the existing
   lenses surface (a saved lens of the AI's takes IS the "column").
3. **The whole-book tutor loop.** A book-scoped grant where the AI adds
   tags, builds a new lesson, she completes it, the AI grades it — a
   turn-taking loop over one book.

## What the use cases imply for the sitting (framing, not rulings)

- **The grant vocabulary is wider than propose-only-vs-full.** Use case 3
  needs book-scoped grants and permissions beyond take-minting: create
  posts (lessons), apply tags — creative acts that are still not
  "edit her text." The graduated grammar likely has more than two rungs;
  which rungs exist is the sitting's to rule.
- **Scope axes surfaced so far:** per-note (her floor, verbatim) and
  per-book (use case 3). Whether grants attach to notes, books, tags, or
  all three is open.
- **The lens is the natural review surface.** Both reviewer shapes (1 and
  2) resolve to "AI takes collected in a saved lens" — machinery that
  already exists; the door mints takes and saves a lens, nothing new in
  the data model.
- **Turn-taking is a workflow, not a mechanism.** The complete-then-grade
  loop needs no new semantics — each turn is ordinary operations under
  the standing grant. Whether the app should *represent* the loop (or
  just permit it) is a sitting question, and the lean should be
  restraint.
- **The standing §9 guardrails carry:** writes land as takes/comments
  through ordinary operations, insure-first; reads scoped by grants with
  TCC-style consent; journals excluded from "always"; nothing an agent
  does can clobber her text by construction (conflict-as-variant's
  doctrine extended to a third writer — the Fragments-bridge precedent).
- **The verification bar from the row:** a propose-only grant PROVABLY
  cannot touch existing takes, test-pinned like any refusal; reads never
  exceed the grant; every AI write is reviewable, undoable, synced like
  her own.

## Boundary against 13h

Ruled 2026-08-19 (the row's creation): 13h stays purely the
folder/markdown bridge; the MCP door is this phase. The two may share
plumbing at build time (both are "an outside writer lands through
ordinary operations"), but their design conversations are separate and
13h's opens first only if she runs it first — no ordering is implied.

## The chat question (author, 2026-08-25, the launch-strategy conversation — OPEN, nothing decided)

*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
interesting to explore the angle of positioning it as an AI *editing*
app instead of an AI writing app - your words stay yours"* — with her
option idea: takes may be AI-edited by permission, **with a commit
before and after so the owner can compare** (the insurance-commit
doctrine extended to an AI edit — nearly free in the model, and worth
naming at the sitting as a first-class demo).

Candidate shape recorded 2026-08-25 (Fable assessment, not a ruling):
**build the MCP server first exactly as this note describes, and treat
any future in-app chat as ANOTHER CLIENT of the same server and the
same grant grammar** — the chat's AI walks through the same doors,
shows the same grants, gets refused by the same refusals. That keeps
the permission story ONE story whether the client is Claude Code, a
local LLM, or an embedded chat; it means the chat decision does not
gate 13n and can be made after watching how the MCP launch lands; and
it makes the only 13n-time obligation a cheap one: don't build
anything that assumes the client is external (auth/token flow an
embedded client could also use). If a chat is later ruled in, it is
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
undecided.
