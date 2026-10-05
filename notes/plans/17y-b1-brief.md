
## 17y B1 BRIEF — the two performance items: (j) the in-note Index scroll · (k) the Library infinite scroll (ONE unit; the pass's LAST batch; USE-SHAPED close)

**(j) THE IN-NOTE INDEX SCROLL'S PERFORMANCE — TRACE FIRST.** Her report verbatim in the row:
"every scroll in this app works beautifully with no lag except for index scroll within a long
note (not the book view, the in note view…)… laggy, sometimes a quick scroll will send you
straight to the top, just bad performance." A P1/P3 violation on its face. The trace covers the
NOTE's index surface FIRST and checks whether the book Index shares the mechanism. The
quick-scroll-to-top smell is the height-estimate/jump-correction family — REQUIRED READING
before touching anything: `notes/TEXTKIT2_NOTES.md` §2 + §3 whole (the macOS-27 findings: the
clip-moving `layoutViewport()`, the stale-frame scroll range, the first-measure drift), the
13u2b/13u4 F3 precedents (honest row heights from `ProseHeightModel`/`FlowHeightEstimate` over
`Queries.blockExtents` — KnownIssues rows 49/61's resolutions are the worked examples), and
KnownIssues rows 87/90 (the landing/settle family's open residue). Mechanisms to rule in/out BY
MEASUREMENT: lazy rows standing at estimates (the F3 class); a scroll-driven re-query storm
(P1's letter — rows re-reading at scroll rate); jump-correction re-aims against moving geometry.
Pin red-on-old at the traced mechanism; the fix follows it (the F3 shape — known heights before
the aim — is the ready precedent IF the trace lands there; never assume it).
**The diff likely reaches the read tier / editor seam ⇒ the cold review is FABLE's (mandatory,
the kickoff's own line).**

**(k) THE LIBRARY'S 40-NOTE WINDOW → INFINITE SCROLL — A LAUNCH BLOCKER (her words in the row:
"completely unacceptable… has to be fixed before launch even").** The located mechanism:
`LibraryCatalogModel.pageSize = 40` with no load-more firing on scroll. The designed road
exists and is the ONLY acceptable shape: KEYSET pagination on the schema's `(stamp, id)` sort
keys with their matching partial indexes (AppSpec §7's three timeline indexes; sort key always
`(position-stamp, id)`) — **never a raised cap, never OFFSET**. Both Library views — List AND
Cards (item (d)'s name) — scroll the whole corpus with zero felt degradation (HER SMOOTHNESS
BAR, verbatim in the row: "needs to be SMOOTH like the rest of the app — no performance losses
are acceptable for it! including if it's in the notes view, which might have a different
performance due to rendering differently"). The day filter, sort menu and search interplay:
every sort the `sort ▾` offers pages on ITS OWN keyset (edited · created · date · title —
check each column's index story; title may need a measured decision, recorded honestly).
P1 discipline: each page is one bounded indexed read; scrolling never re-reads what stands;
the held observation's region stays bounded (the U1 P1-pin pattern — pin the tracked region).
**THE RIDER, hers:** on the "All" screen, "once books hit ~half of the vertical area, books
start to scroll within their own little view, so that many books won't mean you see no notes"
— LOCATE the exact surface her words name (the All screen whose books region can swallow the
notes), cap the books region at ~half the vertical area with internal scroll, pinned.
**EVIDENCE (use-shaped — pins alone CANNOT close this batch):** build a LARGE FIXTURE in the
dev store (hundreds+ of notes — a seeding script, kept under Tools/ or the test support, never
near the real store), a live scroll walk on it (captures + a feel note in your record), both
views, both voices; then the orchestrator's own walk; **the batch and the 17y ENTRY close only
at HER live scroll walk and her word.**

**FENCES:** zero `Sources/VariorumCore/Sync/` · zero schema (the indexes EXIST — if the trace
concludes a NEW index is needed, STOP and report: a schema change is a §12/author event) ·
zero custody · zero mobile · no /Applications refresh inside the batch (the pass-end window).

**ENVIRONMENT:** identical to B2's (the worktree, DerivedData/17y, suite-level -only-testing,
the resiliency protocol, LIVE STATUS as "17y B1 RECORD", no trailers). Perf measurements under
load are untrustworthy — quiet-machine runs for any number you record (the latency-pin row's
lesson); her app untouchable.

**REQUIRED READING:** the 17y row items (j)(k) end to end + the RUN RECORD + this brief ·
`notes/TEXTKIT2_NOTES.md` §2–§3 · KnownIssues rows 22 (the re-owned Library leg)/49/61/87/90 ·
AppSpec §7 (the container indexes + ordering conventions) · `LibraryCatalogModel` +
`LibraryCatalogView` + `LibraryListingReads.swift` · CLAUDE.md + canon.
