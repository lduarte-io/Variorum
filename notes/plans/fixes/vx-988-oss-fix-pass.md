# VX-988 — the OSS fix pass (HEAD edits from the sweep rulings)

**STATUS: IN PROGRESS.** Branch `vx-988-oss-fix-pass` (worktree `~/dev/variorum-vx-988`), off `main` at `fd021908c`.
No PR opened by the implementer; the branch is left pushed for the orchestrator.

## FOR A LATER READER

*(Written at the pass's close; kept current while it runs.)*

**What NOT done, first:** see "Open items" below.

**The mechanism.** The open-source sweep (VX-754: piles A/B/C/P, read by agent eyes) flagged sensitive content
across the history and the tree at HEAD; the author ruled every flag (her rulings R-oss-N, held on the PRIVATE
verdict ledger outside this repo — the ledger never enters the repo, and this record carries ruling ids, classes
and counts only, never a removed value). This pass is the ONE edit of the working tree at HEAD that applies those
rulings. It rewrites no history: the later filter-repo rewrite (VX-749) handles every older version of every
file, and commit messages, the prompt record and transcripts belong to that rewrite and to the packaging work.

**The edits, by work item** (each its own commit; the commit messages describe the edit mechanically):

- **A · R-oss-11 — tester identity.** *(pending)*
- **B · R-oss-20 — the 14b re-key suite email.** *(pending)*
- **C · R-oss-25 — the personal class.** *(pending)*
- **D · R-oss-26 — the OSS plan's own riders.** *(pending)*
- **E · R-oss-23 — two files relocated.** *(pending)*
- **F · R-oss-27 — identifiers.** *(pending)*

**Open items.** *(pending)*

---

## LIVE STATUS

| Item | State | Commit |
|---|---|---|
| record | opened | `d8765d4a8` |
| A | done | `c2c9da936` |
| B | done | `a71e41bac` |
| C | done (four commits: mockup prose · the two screenshots · the intake trim · the two redactions) | `1bdee090e` · `ebd18d17f` · `667d481b7` · `0715f81ee` |
| D | done | `c952778e6` |
| E | done (the private repo's own commit first) | `707684cd2` |
| F | next — the identifier pass | — |
