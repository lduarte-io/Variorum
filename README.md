# Variorum

A native, premium Apple writing tool built around one idea: the atomic unit is the **block** — nothing owns blocks, everything points at them, and every view is a traversal of the same graph. Journals, blog posts, and books over one model, with variant fans, append-only commits, and lineage edges.

Start here: `CLAUDE.md` → `notes/CoreDescription.md` (vision) → `notes/OverallModel.md` (mental model) → `notes/AppSpec.md` (spec) → `notes/DetailedPlanForPhases.md` (build plan).

## A letter from Lillian

Variorum opens with a letter: why I built it, what it's for, and what I hope it does. It's the first note in every new library (and comes back from the Help menu if you delete it), and its text lives in this repository at [`notes/plans/vx-105-letter-content/read-me.txt`](notes/plans/vx-105-letter-content/read-me.txt).

## Open source, closed contribution

Variorum's source is open under the GNU Affero General Public License, version 3. It isn't open to contributions: I don't accept pull requests or patches from anyone, and there's no contributor license agreement to sign instead. That's deliberate, and it's permanent. Being the code's only owner is what lets me relicense it, offer it under a second license beside the AGPL, and ship the iOS app through the App Store. It's the same stance SQLite takes. [CONTRIBUTING.md](CONTRIBUTING.md) says more.

## How it's maintained

Variorum is made by one person, in bursts. Releases go out when they're ready, so a quiet stretch is the rhythm, not a sign the project has stopped.

## Issues and security

Bugs and ideas are welcome as issues. Each one goes into my private work queue and is prioritized there. Security problems go to the address in [SECURITY.md](SECURITY.md), never to a public issue.

## Building it

You can build and test Variorum with no account, no signing identity and no server. [BUILDING.md](BUILDING.md) has the steps.

## Reading the history

Commit messages and notes cite ids like VX-123. They name tickets in a private tracker. The record itself lives here: every commit message says what changed and why, and the larger fixes each have a write-up in [`notes/plans/fixes/`](notes/plans/fixes/).

## The iOS app

The iOS app lives in this repository too, in `App/Variorum/VariorumMobile/`, sharing `App/Variorum/Shared/` with the Mac app. It's in development and hasn't been released.

## License

Copyright (C) 2026 Lillian Duarte.

Variorum is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License, version 3, as published by the Free Software Foundation. It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See [LICENSE](LICENSE) for the full text. The libraries Variorum builds on keep their own licenses; [BUILDING.md](BUILDING.md) lists them.
