# VX-1045 — the Nov 24 sitting: the VX-980 and VX-981 bundles, the coordinator handoff, the Ambient merge, the 1.5 release

**Ticket: VX-1045 · Branch: `vx-1045-nov-24-sitting` · Worktree: `~/dev/variorum-vx-1045` · the Pro**

## FOR A LATER READER

*(Kept current while the sitting runs; rewritten at its close.)*

- **Done at the sitting so far:** PR #8 (VX-997, the Variorum side of the Ambient app) merged at her word, merge
  commit `703c42173`; its worktree, branch and the old tool's build folder removed. A new Linear label, "Ambient",
  sits on all fourteen Ambient tickets. VX-1013 (the slow open) was sized, with measurements (below).
- **Waiting on her:** Apple's developer agreement (the notary service still answered 403 at 14:40 on 2026-11-24);
  her answers on the open calls of QUESTIONS #276 and #278; the five proposed stage-coordinator skill lines; the
  label and notes of 1.5.
- **Owed before 1.5 is built:** the first-run gate again, on main's tip. It passed on `ad5053002`; the phone runs
  that merged afterwards changed shared and core code (among it the local migration v1_38, which is not a lockstep
  event; the marker stays 15).
- **Rulings:** none recorded yet. They land here in her words, then in `notes/QUESTIONS.md` as bundle addenda at
  the close.

## Her words (2026-11-24, verbatim)

Opening the sitting:

"hello fable I want us to handle handoffs from recent VX sessions, get the latest apple agreement signed (where do I
even see that? I opened xcode and did not see it), then once the handoffs are handled, get 1.5 released. I also want
to get the new ambient PR merged - I'm pleased with the ambient app improvements. there were tickets filed for it -
make sure those are tagged "ambient" or something of the sort in Linear. PR #8: still held at your word; it now
carries the coordinator skill's updated Ambient lines"

On VX-1013, quoting the VX-980 handoff's "Slow first launch" lines: "I want to understand how big of an issue this
ticket is"

On the VX-981 handoff: "I might want to handle things like the list order in my upcoming umbrella on book
improvements - not 100% sure on that"

A little later, with the 2026-11-22 coordinator's closing message pasted: "I also was given this by the coordinator -
what are those stage coordinator improvements? we need to handle this as well"

## What was done

### PR #8 (VX-997), merged

Her word is the first quote above. Before the merge, on the Pro: `~/dev/ambient` on its main and level with its
origin; `/Applications/Ambient.app` at build 525; the branch's `Tools/ambient status` answering `OFF` through the
thin door; both scripts parsing; a trial merge with main clean. Main was merged into the branch, the in-flight row
retired and the record's top updated on the branch (`c5a322755`), the PR marked ready and merged with a merge
commit (`703c42173`). After it: main pulled; `Tools/StageAmbient/` (only its ignored build folder was left) removed
from the main checkout; the worktree `~/dev/variorum-vx-997` and the branch removed, locally and on the remote;
`Tools/ambient status` on main answers `OFF`.

Linear closed VX-997 by itself at the merge. Its open members stay seated under it: VX-531, VX-1042, VX-1043,
VX-1044 (all Low, Backlog) and VX-460 (In Progress).

### The Ambient label

A workspace label "Ambient", outside the Area group (that group is single-select and its list is CLAUDE.md's), so it
sits beside a ticket's Area. On: VX-997, VX-1035, VX-1008, VX-1001, VX-1002, VX-1003, VX-1004, VX-1042, VX-1043,
VX-1044, VX-531, VX-460, VX-459, VX-458.

### VX-1013, sized

**The road, read in the code.** Every open (a launch, an unlock, a retry) gathers the protection facts before it
decides anything: `AppBootstrap.beginOpening` → `ProtectionOpenRoad` → `ProtectionFactsGatherer.facts`, whose first
line builds the catalogue (`CatalogLister.catalog()`). The lister reads the whole bytes of every key file under the
library's own `Backups/` and `Previous Libraries/` and under the second backup folder's `Backups/`, one after the
other (`CatalogLister.entry`, `Data(contentsOf:)`). The work is off the main thread, so the app is not frozen, but
nothing draws until it ends. Its cost follows the number of backup copies kept (one key file each), never the size
of the library.

**Measured on the Pro, 2026-11-24, load about 4, online.**

| Folder | Key files | Evicted by iCloud at the time |
|---|---|---|
| The real library's own `Backups/` and `Previous Libraries/` (local disk) | 10, counted by name | none (local) |
| The real second folder, an iCloud Drive folder | 23 | all 23 |
| The dev store's second folder, an iCloud Drive folder | 80 under `Backups/` | none of the key files (95 other files were) |

Three of the real folder's evicted key files, read to nowhere from a shell, took 0.92 s, 0.62 s and 1.05 s each: the
read waits for iCloud to bring the file back. So the first open of the real library after an eviction waits roughly
a second per backup copy before anything draws, about twenty seconds for today's twenty-three, on a quiet Mac that
is online. The nine-minute case was the same road over the dev store's folder (about 155 files, some 80 of them key
files, the only ones whose bytes are read) with the Mac at a load near 100. Once read,
the files stay on the Mac until macOS evicts them again, which is why the next launch that night took ten seconds.

**Not measured:** an open with the folder evicted and the Mac offline (whether each read fails at once or waits out
a timeout); a folder on a network share or a sleeping external disk.

**Reading of its size.** No words are at risk and nothing is written wrongly. What it costs is the open: the wait
grows by one read with every backup the second folder keeps, and it depends on a folder outside the library, on a
service the app does not control. The orchestrator's recommendation, hers to rule: High, Todo, first step the
offline measurement, and not a gate on 1.5 (1.4 walks the same road).

### Read for the sitting

`notes/handoffs/vx-980-handoff.md`, `notes/handoffs/vx-981-handoff.md`, `notes/handoffs/coordinator-2026-11-22-handoff.md`,
QUESTIONS #276 and #278 whole, `notes/plans/vx-981/mcp-parity-audit.md` (the two gap tables and its opening), the
Nov 22 sitting's record on its branch (`notes/plans/vx-1033-nov-22-sitting.md`: P-980-3 was ruled there, option (a);
the five-round cap is answered as the standing rule), and the Ambient repo's `notes/vx-1035-handoff.md`.

### The release's state

- Apple's notary service: `xcrun notarytool history --keychain-profile VariorumNotary` answered "HTTP status code:
  403. A required agreement is missing or has expired." at 14:40.
- `/Applications/Variorum.app` is 1.4 (12299). No Variorum is running.
- The first-run gate passed on `ad5053002`. Since then 195 files outside `notes/` changed on main (the phone runs
  VM-55, VM-78, VM-64, VM-47 and VM-24): 42 of them in the Mac app, `Shared/` and the core, among them
  `v1_38_owner_adoption_index`. The gate is owed again on the tip that is built.
- `ReleaseNotes-1.5.md` and the label 1.5 are still provisional.

## Her rulings

*(None yet.)*

## LIVE STATUS

| When (2026-11-24, MST) | What |
|---|---|
| 14:35 | Bout start: both repos pulled (level). Handoffs, bundles and memory read. |
| 14:40 | The notary check: still 403. |
| 14:45 | VX-1013 traced and measured. |
| 14:49 | PR #8 merged (`703c42173`); cleanup done. |
| 14:50 | The "Ambient" label made and applied to fourteen tickets. |
| 14:52 | VX-1045 minted; this record opened. |
