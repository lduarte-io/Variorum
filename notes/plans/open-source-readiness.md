# Open-source readiness — decision state, the curated record, and the video fact sheet

**Born 2026-11-03** from her open-source sitting (this file is the durable record of that conversation; the tickets live in the Linear project "Open-source readiness"). Status, hardened the same evening: **her stated direction is the FULL story — source code AND all the build documents, moving asap** ("i'm pretty sure i'm just going to be trying to show the whole story and moving asap towards releasing the source code and all of my documents on having built it… i honestly feel good about it"). License still unchosen (AGPL the working lean). The curated edition is thereby DEMOTED from a separate pre-release artifact to the READING-PATHS layer on top of the full release (§2). One launch, not two. Nothing here is a canon ruling; this file exists so no later session re-derives the reasoning.

## 1. The decision state (2026-11-03)

*[removed for publication]*
- **Her constraints:** no maintainer burden (open source, closed contribution — the SQLite stance); she does not want others monetizing it (rules out MIT/Apache); she wants real open source, not source-available (rules out FSL/PolyForm — she asked why they aren't open source: they fail the OSD's no-commercial-restriction floor, and the 2-year conversion doesn't cure today's license).
- **The copyright caveat, planned for:** the code is AI-written under her direction; US protection for it is untested. The plan assumes ZERO copyright protection and builds the moats that need none: a REGISTERED trademark on "Variorum" + the logo (file before the code drops), the server side (entitlements/sync/AI proxy are never forkable), her person + velocity + the record. The license (AGPL lean) is the fence on top, respected by anyone with a lawyer even if its teeth are untested.
*[removed for publication]*
- **History:** she leans toward publishing the REAL history ("showing all my cards at once" — commit ddf04e8b8 "Her paranoia was correct…" is a feature, not a liability). So: targeted `git filter-repo` excision of the few genuinely private files, NEVER a fresh-history republish. The audit produces the excision list.

## 2. The curated record — what is actually shared, story-first

*(Reframed same evening: with the full release decided, this list stops being a privacy fence and becomes the TOUR — the posts, the video and a README-of-the-record that give readers entry points into 6.1M words and 10.7k commits nobody would otherwise navigate. The IN list below is the itinerary; the OUT list becomes VX-754's flag classes rather than withheld material — only other-people's-words, personal-beyond-the-story, credentials machinery and open-security detail stay out of the full release itself.)*

The curated edition is the METHOD, separated from the PRODUCT canon. It is publishable before and independently of any code.

**IN:**
- Her story posts/video (the blog + the AI-copyright video are hers to write; §3 is the fact sheet).
- The working rules: CLAUDE.md's process half (the cast, the ladder, pin-before-fix, the orchestrator-never-implements rule, PROVISIONAL, sizing, the stage) — paths/credentials machinery redacted.
- `notes/REVIEW_PROMPT.md` · `notes/SessionResiliencyProtocol.md` · `notes/PhaseSizingGuidance.md`.
- `notes/ProcessHistory.md` — the dated evolution of the rules, failures included.
- The skills (`.claude/skills/run-phase`, `architect-phase`, `stage-coordinator`) and agent definitions.
- The sync postmortem (`notes/sync-postmortem-fragments.md`) and the crash-out story — honest failure is the credibility engine, her call per incident on how raw.
- **3–5 complete worked examples, end to end** — one sync fix, one editor-seam fix, one author-sitting feature — each with the ruling, the spec line it became, the red pin, the ladder rounds and dispositions, and the shipped diff excerpts. The examples are what make the rules credible; curated ≠ sanitized.
- The QUESTIONS protocol shown by excerpt (how ambiguity reaches her, options + PROVISIONAL + her call).
- The stats page (§3 numbers).

**OUT (until/unless the full open-sourcing):** `SurfaceContracts.md`, the bulk of `AppSpecRecord.md`, `SyncSpec.md`, `CastleRules.md`, `MCPSpec.md`, the ~650 plan files, the 121 handoffs, `notes/TICKETS.md`, `notes/source/` (ESPECIALLY the GitHub-issues export — testers' words are not hers to publish), anything carrying her home path/email, and any security detail whose ticket is still open.

**Pass rules for every published excerpt:** no tester words; her verbatim quotes only where she approves each; no `~/.variorum` machinery, test-account roads or prod operational detail; public copy rules apply (sentence case, no ticket-id soup in prose).

## 3. The video fact sheet — her level of effort, with receipts

The video's thesis as she framed it: *"I want open source; I put a ton of work into this app; and yet every license other than fully-open may not protect me, because AI code may not be copyrightable."* Sharpened: permissive licenses need copyright LEAST, restrictive ones MOST — she is choosing openness while the law can't yet say what's hers.

**Scale (as of 2026-11-03, all verifiable in-repo):**
- 122 days (first commit 2026-07-04 → 1.0 on 2026-11-01), 10,684 commits ≈ 87/day; 82 merged PRs; 19 shipped releases (0.9.x → 1.0.1).
- ~328k lines of non-test Swift; ~401k lines of test code — MORE test than app; 10,771 `@Test` functions.
- ~6.1M words of notes: specs, plans, rulings, run records (987 files; 656 plan files; 99 fix/run records; 121 handoffs).
- The always-loaded "constitution" (CLAUDE.md + the three canon files) is ~129k tokens, re-read by every session and subagent.
- **Her prompting, counted and VERIFIED** (the Pro's `~/.claude/history.jsonl`, which keeps every typed prompt even after transcript cleanup; verified 2026-11-03 by machine-pattern scan — zero agent-message/skill/JSON frames — plus stratified samples read across Jul/Aug/Sep, all her voice): **3,233 prompts · ~230k words of typed prose** (232.6k incl. slash commands) across the four months — Jul ~38.6k · Aug ~52.6k · Sep ~38.2k · Oct ~99k · Nov-to-date ~4k; ≈26 prompts/day averaged, ~57/day in October (October ≈ 2.3× her earlier monthly word rate — the "doubled my productivity" month); plus ~12.4k pasted-in words stored beside them. The surviving full transcripts (Oct 5 →) put her median message at 46 words. Claude's replies to the pre-October prompts are gone (transcript cleanup); the prompts — her half of the authorship record — are all still there. **Archived 2026-11-03** to `~/VariorumArchive/` (the history snapshot + 7.9 GB of surviving transcripts, local copy; off-machine copy pending her call).
- Her raw use reports live in `notes/author-reports/` (four reports, ~9.3k words verbatim); each spawned a dispositioned round file (the two big ones: 11.6k and 11.2k lines).
- 784 tickets minted (VX-747 + VM-37), 520 distinct tickets named in commit subjects; median commit subject 256 characters — the history IS a record, not noise.

**Evidence of human authorship (the Copyright Office's own vocabulary — selection, arrangement, modification, creative control):**
- ~140 distinct numbered rulings in the canon/record (R-ids), ~486 across all notes, plus the S4/U/P families — each a dated product decision of HERS, many with her words verbatim.
- 256 numbered questions batched to her over the project (`notes/QUESTIONS.md`, running at ~150k words); 232 PROVISIONAL calls marked for her ratification — the standing protocol is that agents NEVER invent product behavior.
- Her own typed prose in-repo: the original requirements (verbatim, ~1,430 words), the 4,369-word intake written from real daily use (itself a Variorum export), four use-report rounds (~23k lines of her daily-use feedback, dispositioned row by row), the readme letter, every ruling quote.
- The process is architecture SHE designed: spec-first (every mutation traces to a spec section), pin-before-fix with revert-verified red, a two-review ladder with fresh cold reviewers, Fable mandatory on sync/custody/editor-seam diffs, the orchestrator forbidden to implement. The record documents who decided what, when, in whose words — which is exactly the evidence the human-authorship question turns on.

**The legal frame (VERIFIED 2026-11-03 by a sourced web-research brief — an Opus subagent; primary sources where marked; none of this is legal advice):**
- **The core test is unchanged since mid-2025.** The operative guidance is still the Part 2 report (Jan 2025): purely AI-generated material isn't protectable, prompts alone aren't authorship, human selection/arrangement/modification can be, case by case. No new Office guidance, no Compendium update, no disclosure-rule change (copyright.gov/ai, checked 2026-11-03).
- ***Thaler* is over: cert DENIED 2026-03-02** (No. 25-449, supremecourt.gov docket). Not a merits ruling — Thaler disclaimed all human contribution, so "how much human input is enough" was never reached. The likely first court test of human DIRECTION is *Allen v. Perlmutter* (D. Colo.), cross-MSJs fully briefed, undecided as of Sept 2026 — about images. **No US court has ruled on copyright in AI- or agent-written CODE.**
- ***Doe v. GitHub* (9th Cir. No. 24-7700, decided 2026-09-16):** the Copilot DMCA §1202(b) theory is dead ("Copilot creates new work"); the opinion says nothing about who owns AI output; what SURVIVES (before Judge Tigar) are the open-source **license-as-contract** claims. Practitioner commentary expects enforcement to shift to contract — a theory that does not require copyright in every AI-written line. Directly relevant to the AGPL fence.
- **Office practice for software:** programs register with exclusions like "source code generated by artificial intelligence (GitHub Copilot)" (Adobe and IBM products among public examples); 6,000–7,000+ registrations with AI disclaimers by mid-2026 (Perlmutter Senate testimony 2026-05-12). A Variorum registration would cover her specs/docs/human-written parts and any claimed selection+arrangement, agent code excluded. Examiners now send AI-suspicion query letters on literary works.
- **Arkansas Act 927** (eff. 2025-08-05): the person providing the "input or directive" owns generated content — a state statute encoding her exact intuition; no remedies, federal-preemption risk flagged, Iowa's copy died in committee, nothing federal moving on output copyrightability.
- **The ecosystem is split; her posture matches the safest published recommendation:** SFC (2026-06-18): "'Copyleft Everything' remains the best viable and safest approach," disclose AI machine-readably in commit logs; FSFE legal column (2026-08-25): wholly LLM-generated output can't carry copyleft terms at all; the kernel, Debian and Fedora accept AI code under human responsibility; GCC, QEMU, NetBSD and Gentoo decline it on copyright grounds; OSI has no official position.
- **The mirror threat is live and untested:** chardet 7.0 (2026-03) — an LGPL library rewritten with Claude and relicensed MIT, disputed, unlitigated; "MALUS," a satirical clean-room-as-a-service using agents to strip copyleft. The AI-rewrite-as-license-escape question is unsettled in BOTH directions.
- UK contrast stands: CDPA s.9(3) names the person who made the arrangements as author of a computer-generated work; the US has no equivalent.
- Key links: supremecourt.gov/docket (25-449) · cdn.ca9.uscourts.gov/datastore/opinions/2026/09/16/24-7700.pdf · sfconservancy.org/llm-gen-ai/ · fsfe.org/news/2026/news-20260825-01.en.html · mayerbrown.com "Mind the Gap" (Arkansas Act 927) · copyright.gov/ai.

## 4. Readiness checklist (the Linear project mirrors this)

1. **Full-history privacy & secrets audit** — gitleaks/trufflehog over all 10.7k commits; inventory of tester content (the GitHub-issues export above all), her personal paths/email, credential-adjacent files ever committed; a per-file keep/excise/redact verdict list.
2. **History excision rehearsal** — targeted `git filter-repo` from the verdict list, rehearsed on a clone, preserving the trail; the publish-the-real-history question answered with evidence.
3. **License + trademark package** — her final license call (AGPL lean); LICENSE in repo; per-dependency compatibility check (GRDB SQLCipher fork, swift-dependencies, MCP swift-sdk, CArgon2, the BIP-39 wordlist); the TRADEMARK FILING (her hands, before any code drop).
4. **Security pass over open tickets & records** — no still-open Castle/sync/MCP finding may ship as a public roadmap; fix or defer each before the records go out.
5. **Public repo mechanics** — README stance (open source, closed contribution), CONTRIBUTING + PR auto-close, SECURITY.md disclosure contact, the outsider build road (no sync, no signing, no stage).
6. **Curated record assembly** — §2's IN list built, her editorial pass, the worked examples chosen.
7. **The deep content sweep (VX-754, fan-out authorized by her 2026-11-03)** — everything in the share-set READ by eyes, not just scanned: every commit message, the full notes tree, skills/Tools/Server, code comments and strings, and the prompt record if she ships it. Flags, she rules; feeds VX-748's verdict list and VX-749's rehearsal.
- The ticket map: VX-748 audit · VX-749 history rehearsal · VX-750 license+trademark (Needs Lillian) · VX-751 security pass · VX-752 repo mechanics · VX-753 the tour (reframed) · VX-754 deep sweep · VX-747 the open format (rides 13m).
*[removed for publication]*
