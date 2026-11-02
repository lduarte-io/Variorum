# VX-724 — The book's position line moves to a bottom bar (+ the 1.0 release)

**STATUS: OPEN — kickoff 2026-11-01.** Branch `vx-724-book-position-bottom-bar`, worktree `~/dev/variorum-vx-724`, the Pro. Architect shape (her word: "/architect-phase discipline"); Fable orchestrates, Opus implements, Opus cold-reviews (no editor seam, no `Sync/`, no custody, no default's-meaning content). The 1.0 release rides this ticket and runs AFTER the merge, at the standing release road.

## FOR A LATER READER

*(Written at closeout.)*

## HER ASK (2026-11-01, verbatim)

> "on a book, this part that says where you are in the book - I think it's ugly having it at the top of the book, looks crowded and not good. please just move it to the bottom bar of the book view, instead of the top. also, I would change it so that the information that isn't changing is to the right, separated. like 13 chapters, 13 notes, can probably be at the right. i know i asked for this feature but honestly i'm struggling with how I find it ugly. I don't really know where else it would go though. so yeah, I want that change made."

Same message, the release word: "I want to put the version 1.0 out into the world + on the website … I'll actually fix the wording notes myself for release once you're done with this page and then you'll put it straight on the stargazing.tech website (and this is version 1.0)."

**Ruling recorded:** R-724-1 — the book's nav/position info moves from above the page to a bottom bar; the static counts sit at the bar's RIGHT, separated; the changing position info is the other, leading half. This supersedes the placement half of P-562-3 ("stays fixed at the top while scrolling" — the FIXED-while-scrolling half survives; the AT-THE-TOP half is hers to move and she moved it). The one-wording-brain and one-total laws (VX-562 r1 finding 3, `NoteBoxCopy.viewedLine`) are untouched.

## THE SURFACE TODAY (read these, in this order)

- `App/Variorum/Variorum/Features/BookView/BookOutlineViewed.swift` — the whole file (the viewed-pair brain, `positionLine`, `pinLine`, `NoteTotal`).
- `App/Variorum/Variorum/Features/BookView/BookView.swift` — the `.outline` arm of the mode switch (~line 321–345: the `VStack` of `BookArchivedLine` / `OutlinePinnedLine` / `outlineBody`, and the `pageFootReceipt` overlay on that stack); `OutlinePinnedLine` (~line 3344–3430, including the DEBUG oracle calls); `BookViewCopy.metaLine` + `outlinePinLine` (~line 4187–4230); the oracle stores `BookOutlineGeometry.outlinePinLines` / `outlinePinFrames` / `recordOutlinePin(Frame)` (~line 2904/2971).
- `App/Variorum/Variorum/Core/Views/NoteBox.swift` — `NoteBoxCopy.viewedLine` (~line 196; read-only context, the shared wording brain — do not change it).
- `App/Variorum/VariorumTests/BookOutlineViewedTests.swift` — the pure pins on `pinLine`/`positionLine`.
- `App/Variorum/VariorumTests/BookOutlineLandingTests.swift` — the mounted-window pins on `outlinePinLines`/`outlinePinFrames` (~lines 1395–1960).
- `notes/SurfaceContracts.md`, "The Outline follows the page (VX-562)" paragraph — the contract line that changes at closeout (the orchestrator lands the canon delta at merge; you do NOT touch SurfaceContracts).

## THE DESIGN (build exactly this)

1. **The line leaves the top.** `OutlinePinnedLine` stops rendering above the page. In the `.outline` arm the stack becomes: `BookArchivedLine` · `outlineBody` · the new **bottom bar**. The bar is a SIBLING BELOW the page's scroll, never inside it — the same geometry argument as the old top placement (landings measure anchor tops in the scroll's own space; chrome outside the scroll moves nothing).
2. **The bar's two halves.** One `HStack`: LEADING, the position words while a pair is viewed — `BookOutlineViewed.positionLine` ("note 5 of 13 · a scandal in bohemia"), empty at rest; a `Spacer`; TRAILING, the static counts — `BookViewCopy.metaLine` ("book · 13 chapters · 13 notes", plus the set-aside piece when present). Both halves from the ONE `NoteTotal` (the r1-finding-3 law: the two halves can never say two totals).
3. **Styling.** The same voice as today: `tokens.small`, `tokens.muted`, `lineLimit(1)`, tail truncation, `.padding(.horizontal, 20)`, `.padding(.vertical, 6)`. The hairline moves to the bar's TOP edge (the page's bottom edge, drawn — the same `tokens.line` 1-pt rectangle). The bar runs the pane's width (a bottom bar, not a prose-column-caged line) — PROVISIONAL P-724-1. Under width pressure the POSITION half wins (`layoutPriority(1)`) and the counts truncate — the position is the half she reads while scrolling — PROVISIONAL P-724-2. Neither half ever wraps (P-8).
4. **The receipt overlay.** Today `pageFootReceipt` overlays `bottomTrailing` on the whole outline stack; with a bar there it would sit on the counts. Move that overlay onto `outlineBody` alone, so the receipt floats at the page's foot, above the bar. No change to `BookNoteBox.quietReceiptHome` — PROVISIONAL P-724-3.
5. **Copy plumbing.** `BookViewCopy.outlinePinLine` (the joiner) loses its render consumer. Keep `pinLine`/`outlinePinLine` ONLY if the oracle still wants one joined sentence (your call, stated in LIVE STATUS); otherwise retire them and their pins deliberately. `positionLine` and `metaLine` stay as-is — they are the two halves.
6. **The DEBUG oracle.** Keep `recordOutlinePin` + `recordOutlinePinFrame` recording the BAR's content and frame. The recorded line should capture both halves unambiguously (e.g. record the two halves joined in the bar's reading order, position first — your call, stated). Update `BookOutlineLandingTests`' expected strings to the new shape; the "pin stands still while the page scrolls" frame assertion must survive (a bottom bar outside the scroll stands just as still). The at-rest assertion ("counts alone") survives with the counts in the trailing half.
7. **Nothing else moves.** The title block keeps title + expand/collapse doors exactly as-is (the counts do NOT return to it — P-562-3's no-duplication half stands). The masthead, navigator, Index/Read/spread arms, `NoteBoxCopy`, the follower/adoption machinery: untouched. Outline remains the only mode drawing this line, exactly as today.

## SCOPE FENCES

- No `Sources/VariorumCore/` changes. No editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier). No `Sync/`, no custody.
- No capability-registry change (the bar has no doors).
- No new settings, no new copy brains — reuse `positionLine`/`metaLine`.
- SurfaceContracts/AppSpec are the orchestrator's at closeout, never yours.

## TESTS & EVIDENCE (the acceptance unit)

ONE acceptance unit: the bar, verified by its kind — the updated mounted-window pins green plus the orchestrator's hands-on screenshot walk.

- `swift build` is not enough — this is app-target work: `xcodebuild -scheme Variorum -destination 'platform=macOS' test -only-testing:VariorumTests/BookOutlineViewedTests -only-testing:VariorumTests/BookOutlineLandingTests` **under a HELD `Tools/stage` claim** (the suites mount windows and share the dev-store defaults). Confirm the "Test run with N tests" line.
- The changed pins are the red-on-old evidence for the moved shape: the OLD expected strings/placement fail on the new code and vice versa — note in LIVE STATUS which pins changed and why each new expectation is the design above.
- A broader sanity pass is the orchestrator's at the ladder; you run the two suites above plus any suite your diff's types appear in (grep the tests for `OutlinePinnedLine`, `outlinePinLine`, `metaLine` consumers).

## ENVIRONMENT TRAPS (the standing core)

Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by path; treat real-store instances by STORE — never quit/kill one; no Release builds or `/Applications` refreshes. Mac tests from `App/Variorum/`, suite-level `-only-testing` only. NEVER add a custom build configuration. zsh `pipestatus`. Never `git checkout` over uncommitted work. Commit per piece, push after every commit, LIVE STATUS from the first commit (`notes/SessionResiliencyProtocol.md` binds). Work ONLY in `~/dev/variorum-vx-724`. The stage claim: `Tools/stage claim vx-724 "<reason>"` — check `Tools/stage status` first; release it when the suites finish.

## LIVE STATUS

*(The implementer's table, from the first commit.)*

## LADDER

*(Findings and dispositions land here before any fix session sees them.)*

## THE RELEASE (the orchestrator's half, after the merge)

Version **1.0** (`release.sh --version 1.0` — the script stamps MARKETING_VERSION; X.Y is a legal shape). Her word is explicit and standing (this message); the notes are HERS to word ("I'll actually fix the wording notes myself") — the orchestrator drafts `ReleaseNotes-1.0.md` as clean public copy (one line per bullet, no draft/meta/process lines — VX-708's rule), presents it in chat, lands her fixes on the branch before the merge so main is release-ready. Then: PR merge (merge commit) → `Tools/Release/release.sh --version 1.0` at a zero-instance window, no repo commits while it runs → the site road per `~/dev/stargazing.tech/stargazing-tech/notes/variorum-releases.md` (DMG-first: R2 put → verify dmg → appcast copy → `variorum.json` bump → build+deploy → verify appcast) → A1 safety copy + `/Applications` refresh at a zero-instance window.
