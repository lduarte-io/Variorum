# A map of this record

This repository contains a finished Mac app and the complete working record of how it was built: about 6.1 million words of design documents, plans, rulings and fix records, alongside more than 12,000 commits over four months. It was built by one person directing AI agents, and the record was written primarily *for those agents* — so it uses a private shorthand. This file is the translator and the map.

## A note from the author

It was a deliberate choice to let AI control the docs and its own notes completely — I rarely look at these directly myself. I've found that AI performs better in my experience when allowed to work with its own AI-language. Basically, what's unintelligible to me seems to be an advantage to them, and I can see why it helps given that certain words start to develop a new definition within the context of this repo. I simply ask whatever its jargon means, as many times as necessary, when going through questions and handling issues. Generally, letting Claude manage its own memory files and context has proven quite effective in my experience. I did switch to using Linear halfway through the project instead of keeping track purely in files because maintaining to-dos by hand was proving nightmarish. The AI tendency to add work to records in a convoluted way (the Phase 13b plan file is the canonical example — it grew until it broke the process's own rule that a plan be readable whole, and the splitting lesson it forced is written into notes/PhaseSizingGuidance.md) combined with the fragility of that approach to multiple sessions writing concurrently ultimately made it unfeasible. So while looking through everything holistically, there is a sudden drop off where that planning element was removed from the repo, which in turn facilitated a month of significantly faster delivery. There's also unreleased work - both the iPhone app (which I use daily but which is still too underdeveloped for others) and certain modes (like Canvas) that I have not yet had the time to bring up to standard. It's easy to build out too much, too quickly, with AI. You can see through this history that the parts of the app that I valued most - performance, encryption, an editor that works like a normal editor on the surface despite underlying complexity - were returned to many times. I hope it's of interest to you.

## The layout

- `Sources/VariorumCore/` — the Swift package: models, persistence, the operations API, domain rules, sync, protection. The product's brain.
- `App/Variorum/` — the Mac app target and the shared cross-platform faces. `VariorumMobile/` is the iPhone app — real and in daily use, but not publicly released yet.
- `Server/` — the SQL deployed to the sync backend.
- `Tools/` — scripts: builds, releases, the GUI-walk harness, the guarded production-read road.
- `notes/` — everything else: the canon, the plans, the history. You are here.
- `.claude/` — the AI configuration: agent definitions, skills, the rules every session read.

## The canon — what is true

Nine documents carry the product's truth, in authority order. Every working session was required to read the first four before touching anything.

1. **CoreDescription.md** — the vision: why the app exists, in the author's terms.
2. **OverallModel.md** — the mental model: the whole system in one sentence, the invariants, and §8, every architecture decision with its rejected alternatives. If you read one file, read this one.
3. **AppSpec.md** — the contract: the schema, every operation's exact rules, the performance budget.
4. **CLAUDE.md** (repo root) — the working rules the agents ran under.
5. **SurfaceContracts.md** — every user-facing surface's full ruled behavior.
6. **SyncSpec.md** — the sync protocol, conflict handling, the encrypted wire.
7. **CastleRules.md** — the 27 rules of library protection.
8. **MCPSpec.md** — the AI door's contract (the app's own AI integration).
9. **AppSpecRecord.md** — the living record: the dated *why* behind every rule above, with the author's rulings in her words. Nothing is ever deleted from it.

## The dialect

The notes use a house vocabulary. The load-bearing terms:

- **A door** — any way a user action enters the system (a menu item, a shortcut, an API call).
- **A ruling** — a product decision made by the author, recorded with a date and usually her verbatim words. Agents never invented product behavior; where the spec was silent, they asked. Open questions lived in `notes/QUESTIONS.md`, numbered.
- **A sitting** — a session where the author answered a batch of questions.
- **A pin** — a test written to fail on the old code before a fix, proven by reverting the fix. No bug fix landed without one.
- **The ladder** — the review process: an implementer's work gets a cold review by a separate agent with no context from the implementation; findings get fixed; a fresh reviewer re-checks. Up to three rounds.
- **A run / a phase** — a unit of work with its own plan file, branch and pull request.
- **A run record / fix record** — the file in `notes/plans/` or `notes/plans/fixes/` that holds an effort's full story. Each opens with a FOR A LATER READER section — the summary — above the night's raw working log.
- **A handoff** — the end-of-effort summary written for the author, in `notes/handoffs/`.
- **A walk** — a scripted GUI session driving the real app to verify behavior on screen.

## How a change landed

Every change followed the same road: a ticket → a branch named for it → an implementer agent builds with tests → the cold-review ladder → the author's word → a merge commit to main. Product decisions moved in the opposite direction: the author ruled (often in a sitting), the ruling landed in the canon in place, and the dated reasoning was appended to AppSpecRecord.md. The commit history is the honest trace of all of it — including the 3 AM hours.

## Reading paths

- **The product**: CoreDescription → OverallModel → skim AppSpec §9.
- **The process**: CLAUDE.md → any recent fix record's FOR A LATER READER section (notes/plans/fixes/vx-494-catchup-hang.md is a good one: a production sync crisis traced to its real mechanism in one night) → a handoff.
- **The origin**: notes/source/ — the original requirements, the first spec, and the design-chat transcript where the core architecture was chosen.
- **The story**: notes/author-reports/ — the author's own use reports, as she wrote them (the privacy pass's markers apply here as everywhere).

## What was removed, and how to verify what's here

Before publication, a privacy pass removed personal information, other people's details, credential values, and business material. A `*[removed for publication]*` marker stands wherever a passage was cut; identifiers appear as `<placeholders>`. Nothing else was altered, and the history was rewritten with the same rules so the removals hold in every old commit.

If you want to verify the authorship claims rather than take them on faith: the author's prompt record is published separately — the instructions she typed, in order, with the same documented privacy exclusions as the repo (business, employer and personal classes; the exclusions are named there, not hidden), the rulings in AppSpecRecord.md are dated and quoted, and the commit cadence is its own evidence. The record is large precisely because nothing was staged after the fact.
