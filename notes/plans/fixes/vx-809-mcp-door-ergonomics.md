# VX-809 — Umbrella: MCP door ergonomics (the agent-side asks)

**Ticket: VX-809 · Branch: `vx-809-mcp-door-ergonomics` · Worktree: `~/dev/variorum-vx-809` · the Pro · Coordinator: nov4coordinator**

**STATUS: OPEN — kicked off 2026-11-05 (/architect-phase). Batches not yet started.**

## FOR A LATER READER

*(Written at closeout. Until then, the LIVE STATUS ledger below is the run's state.)*

---

## The run

The 2026-11-04 marathon sitting's MCP WRITE-side umbrella, re-cut into WAVE 1 at her word **so the hidden-count privacy fix (VX-825) builds early**. Members are VX-809's SUB-ISSUES (the sub-issue listing is the roster — the VX-548 rule; listed 2026-11-05 at kickoff, 10 members — three more than the description names, all seated by her):

**VX-825** (LEAD — the pure-function law) · **VX-807** (move_book_to_wing) · **VX-812** (bulk forms + replace_tag) · **VX-813** (book order on the wire) · **VX-814** (create_note tags at birth) · **VX-818** (the server survives the Castle lock) · **VX-826** (duplicate's date-title remainder, Bug) · **VX-679** (the AI sidebar section — sitting-ruled in detail on the ticket) · **VX-846** (docs tail, Wording).

**VX-840 RE-SEATED OUT (2026-11-05, mid-kickoff — the roster is NINE):** seated here at kickoff (her Nov 4 "joins VX-809's run" word), then ruled into VX-828 at her vx-828 sitting the same night ("Keep it in VX-828" — the Settings ▸ Tags pane is already open there via VX-838); VERIFIED on Linear (parentId VX-828, In Progress there). What remains ours (the coordinator's assignment): **this run MINTS the shared unused-tags brain** (batch 1's F-3 arm — reach-scoped on the wire; true-count-capable for her surface); its name, home and signature are relayed to vx-828 + the coordinator when it settles, so VX-828 consumes it rather than minting a twin, and whoever merges second re-runs both consumers' tests.

Every design ruling is ON the member tickets (her sitting's structure — "kickoffs need no chat context"); this file quotes what binds and adds the orchestrator's briefs.

**Preflight (DONE at kickoff, nothing delegated):** CLAUDE.md + auto-loaded canon · master plan in-flight table · `notes/TICKETS.md` · `notes/QUESTIONS.md` #258 (the P-771 bundle + the pure-function amendment) · `notes/SessionResiliencyProtocol.md` · `notes/SurfaceContracts.md` IN FULL · `notes/MCPSpec.md` IN FULL · `notes/CastleRules.md` IN FULL (VX-818) · the VX-771 record's FOR A LATER READER + batch-plan geography. SyncSpec NOT read: no Sync/, custody or schema work is expected; **if any migration appears, SyncSpec becomes binding reading for that batch and the coordinator is told before it lands** (the VX-771 numbering rule).

**Constraints:** NO Sync/ or custody (VX-805 holds the slot). VX-818 is protection-ADJACENT only — the MCP server's lifecycle around the lock; nothing in `Sources/VariorumCore/Protection/`; `MacWillLock.swift`'s teardown order is LOAD-BEARING (VX-394/VX-548) — any order change is PROVISIONAL + a bundle line, aim untouched. Stage via nov4coordinator only (headless work needs none; the closing Mac window and any walk do). NO release. Merge serializes through the coordinator (wave 1; VX-828 and VX-805 run alongside).

**Known overlaps (declared in the in-flight row; the coordinator's fences accepted 2026-11-05):** VX-828's VX-838 touches Settings ▸ Tags (my VX-840's pane); its VX-844/VX-833 neighbor VX-679's sidebar section; its VX-824/798 add chords in `Registry/Capability*.swift` — **if VX-679 declares a capability that's a THREE-WAY registry overlap (828 · 805 · us); the second merger re-runs `CapabilityRegistryTests` + `ShellChromeTests` + the Settings/sidebar pane suites after merge-in** (the coordinator trial-merges at every merge). VX-805's surface list includes Operations' WingBookMove and VX-435 (the movable Journal) — the semantic half is settled by R-805-5 (her rulings below); whichever run merges second re-checks `move_book_to_wing`'s tests AND its tool description/fence lines against the other's semantics. Any `App/Variorum/Shared/` file in our diff adds the phone simulator suites to the merge gate. **`Domain/DuplicateDay` IS SHARED tonight (corrected 2026-11-05, vx-805 + coordinator):** vx-805's VX-845 (her ruled F-1(c)) widens its CALL SITES (promoteLens, divergePostForReading, the ownership forks) while our VX-826/P-809-7 widens its CLASS (journal-profile sources) — semantically additive, textually colliding; the second merger reconciles the file + its suite and re-runs the DuplicateDay + operations date tests on the merged tree; our change stays SMALL AND LOCAL so the reconcile is mechanical. Residuals BOTH runs preserve byte-for-byte: a TYPED-titled undated source's copy stays undated; saved versions stay date-cleared. vx-805's VX-797 scopes "the day's first entry" to the Journal's MEMBERS, so our journal-dated copy class is naturally excluded there.

**Coordinator fences (nov4coordinator, 2026-11-05, accepted):** the Sync/-custody slot is VX-805's — we are fenced off `Sources/VariorumCore/Sync/`, `Sources/VariorumCore/Protection/` and custody/keychain code (store-key handling, unlock/StoreUnlock, the Protection road). VX-818's files (`App/Variorum/Variorum/MacWillLock.swift`, `Sources/VariorumMCP/MCPServerHost.swift`) are cleared WITHOUT the slot; the moment a VX-818 edit needs a line in Protection/, custody or keychain code — STOP and ask the coordinator (it waits for the slot or splits out). **The Castle design is FROZEN (her word): fixes live in acts, doors and words, never in rules or anything stored.** Any teardown-order change: PROVISIONAL + bundle line + a red-on-old pin through `MacWillLockTests`. Migrations: tell the coordinator BEFORE one lands (VX-808 will mint one in wave 2; numbers must not collide). P-781-4 is now a CLAUDE.md author-only line: moving an existing dependency's pinned version is hers alone. Stage protocol: REQUEST (what, minutes, claim name) early · READY ping · GO only from the coordinator with the exact claim line (a free stage is never an invitation) · RELEASE + one result line with EXECUTED counts per suite (`-only-testing` takes a zsh array of TYPE names; "Executed 0" is no verdict); strict instance guards `pgrep -lx Variorum` / `pgrep -lf "MacOS/Variorum$"`; after a Debug launch dismiss What's New; a window ≥1 h runs tests first and pings SEAM before any dev-store copy; a merge ask names the tree the last WHOLE-TARGET run tested. Dev store: Standard + MCP switch OFF (restored md5-identical by the 1.1 release walk, signed out); a Castle crossing uses exactly `~/.variorum/dev-castle.env`, Opus drives, posture restored to Standard + switch OFF at release; if Debug prefs are restored, re-export and diff (`defaults import` merges).

**Cast (standing default; she gave no kickoff redirect):** Fable orchestrates (this session) and cold-reviews the ladder (`fable-reviewer` — the run changes the fence's MEANING door-wide and the lock posture, squarely the Fable class), Opus implements (`opus-implementer`, xhigh), ONE at a time, a fresh implementer per batch, a fresh reviewer per round. Cross-model ladder flow per CLAUDE.md. **Any live Castle walk is Opus's, never Fable's** (the standing safeguard).

## Her rulings (verbatim-faithful, from the tickets — the tickets remain the source)

- **R-825 (THE LAW, 2026-11-04, the planning session):** "every MCP answer is a PURE FUNCTION OF THE CLIENT'S REACHABLE STATE — nothing on the wire may vary with what the client cannot reach." Her words: "yes, i agree," arrived at through her own question — "does this fulfill my marketing promises of 'invisible'? the book subject alone could tell you something." Consequences, all landing at this run: (1) the counted-not-named class RETIRES — `still_in_books_hidden_count`, the hidden-counting arms of `duplicate_note`'s `landed` and `move_note_to_wing`'s `left_books` (reach-named parts stay); R-771-A's doctrine SUPERSEDED. (2) In their place, FIXED SCOPE WORDS — byte-identical whether hidden things exist or not ("books beyond your reach, if any, are not listed") — honesty by humility. (3) Reads stay strict; the 807/812/817 fence lines stand; the pure-function sentence becomes MCPSpec's general law, PINNED: an answer must not differ between a hidden-things-exist store and a none-exist store. The record's framing: a shipped over-exposure, narrow (own-account clients; no names, no content), live since VX-771's merge, fixed here.
- **R-825-sweep (same session):** refusals are answers too. (a) THE NAME GUARD resolves cleanly — duplicate names legal, a collision with a hidden book simply creates the twin (VX-259/VX-363 already shipped this; VERIFY + pin). (b) THE OWNERSHIP REFUSALS (`noteOwnedElsewhere`/`noteMemberedElsewhere` while the claiming book is hidden) can't "just succeed" (ownership is real) — the run DESIGNS their reach-pure shape deliberately. (c) The two-store pin enumerates EVERY tool's arms, refusals included — the whole catalog, never only the three counted answers.
- **R-807 (fence line, the disclosure audit):** the app's confirm shows HER everything; the WIRE's answer reach-scopes — severed stay-behind memberships named only where the other book is within read reach; unreadable ones neither named nor counted. Her fuller paste: the op answers what the app's confirm shows (the notes that come, the memberships cut, the waiting arrivals dismissed). The daily Journal refuses the move until VX-435 ships, then follows its rule.
- **R-812 (fence line):** "across a wing" means across the client's REACH in that wing — the sweep acts on and counts ONLY what the client can see; hidden wearers of tag A are untouched, unmentioned and uncounted. Shape: list arguments on the acts that already exist (each item still its own operation, grant-checked and ⌥⌘Z-entried per the door's rules; one call, N receipts), plus replace-tag-A-with-B; MCPSpec decides undo granularity and the receipt shape (one line naming the count, like the app's bulk bars).
- **R-813:** order is plain book configuration; her state doors (Finished, Seal, Own, Private) stay hers alone. An order option on create_book and set_book_rule too, not only a standalone setter.
- **R-818:** the honest split — the reconnect is the CLIENT's; what the app CAN do is never drop the connection: the server keeps listening across the Castle lock, answering every call while locked with one typed "library is locked" refusal, and resumes serving on unlock. The same posture covers any other moment the store is briefly unavailable. The locked refusal leaks NOTHING (no titles, no counts — one flat sentence). CastleRules read before changing anything the app says or does around the lock.
- **R-826:** a date-titled note's copy reads the SOURCE's displayed title, never today's. Pin against the exact repro; check the app's own duplicate doors (the rule is shared — `Domain/DuplicateDay`).
- **R-840 (her second call, superseding her first no-wave word):** it JOINS this run as VX-825's app-side twin — the two share the unused-tags query (reach-scoped on the wire, true on her surface); 825's propose-then-she-deletes story needs this door. Kickoff judgment carried on the ticket with her lean: a tag whose only wearers are in the Trash is "probably 'not unused'" (applications revive with a restore).
- **R-679 (the sitting, via question tool + her refinements):** a NEW sidebar section of its own, NOT under Open — near the sidebar's BOTTOM, about three rows reserved (scrolling within when more), the whole section GONE when there are no requests; "From ‹client› · N"; each row names the place, the kind (shown · opened · edited) and when; clicking the row's TEXT lands exactly where the offer would have; each row wears the shared-with-AI symbol, and THAT SYMBOL IS ITSELF A DOOR — clicking it opens the request's details (the client, when, what kind of act — a navigation ask · a write and which operation — and the target). Session-scoped; rows accumulate from show_in_app asks and AI writes (⌥⌘O generalized; ⌥⌘O keeps jumping to the LAST change).
- **R-805-5 (HER RULING, relayed by nov4coordinator from vx-805's run record, 2026-11-05): THE WIRE KEEPS A JOURNAL REFUSAL.** Moving the daily Journal across wings stays hers alone on the MCP side, even after VX-435 lifts the operation's refusal for her own doors. Build `move_book_to_wing` against today's op refusal as-is; **pin the behavior AT THE WIRE** — a tool-level test asserting the daily Journal refuses with its refusal shape, not only through the op — so either merge order is protected (if 805 merges first, our merge-in routes the tool through 805's wire-side fence and this pin is what goes red if that wiring is missed; if we merge first, 805 wires its fence into our tool and the pin proves it held).
- **R-846:** the VX-771 handoff's O-3/O-4 tail; the guide's cards were never exhaustive — decide whether they should name create_gathering, the remove_tag report, the replace form; `MCPSession.instructions` at 3,061/3,100 left untouched; remove_tag's create_gathering pointer gains the lesser-grant wording ("ask the author for a gathering"). MCPSpec governs; **wording hers at the build** (drafts PROVISIONAL, bundled).

## Orchestrator adjudications (repo-first; A-809-N as they land)

- **A-809-1 (kickoff — VX-840's Trash judgment):** ~~build her lean~~ **TRANSFERRED with VX-840's re-seat into VX-828** — the lean rides the ticket text for their build; **P-809-5 is RETIRED from this run's bundle** (nothing built here; the label is not reused).
- **A-809-2 (kickoff — VX-807's grant shape):** EDIT on the book + WRITE NEW on the destination wing, both decided before the act, once grants of both sides spent together — `move_note_to_wing`'s exact precedent lifted one level. The implementer verifies nothing in MCPSpec contradicts at book level; a surprise goes to me before building.
- **A-809-3 (kickoff — batch order):** VX-825 builds FIRST (her wave-1 reason); every later answer builds TO the law, and the two-store catalog pin grows arms as batches 2–3 add tools.
- **A-809-4 (batch 1, FORK F-2 — the ownership refusals, P-809-2):** **shape (a) rules**, stated as a principle the whole door builds to from now on: **a wire refusal may speak a fact OF A READABLE ENTITY in her doors' words; a refusal whose CAUSE is a fact of an UNREADABLE entity speaks ONE fixed sentence per act family — no name, no count, no kind.** Applied: (1) `add_note_to_book`'s ownership refusal — reachable claimant ⇒ her table's words stand (they describe readable state; pure across the two stores); every claimant unreadable ⇒ the one fixed sentence (the proposal's wording built as drafted, PROVISIONAL P-809-2, hers to reword: *"That note can't be added to this book — something beyond your reach holds it. The author can add it in Variorum."*). The owned-vs-membered KIND collapses in the hidden arm — that distinction is a fact of the unreadable claimant. (2) **S-2 FOLDS IN:** `move_note_to_wing` blocked by a finished/sealed book — readable ⇒ today's named words; unreadable ⇒ the fixed sentence in the move's verb, never "finished"/"sealed" (those are the hidden book's facts). (3) **S-1 (capacity) KEEPS HER WORDS and QUESTIONS #218 STANDS, folded under the principle:** fullness is a fact of the ADD-TARGET book, which the client reads — the refusal describes a readable entity's state; the hidden-members inference behind it is the forced bit she accepted at #218. Re-recorded in the bundle beside P-809-2 so her ratify sees the family whole. The forced bit (a refusal where the none-exist store succeeds) is the law's ONE recorded exception CLASS; the two-store catalog pin asserts these arms as the ONLY differing rows, each differing exactly this way.
- **A-809-8 (batch 1, FORK F-1 — the scope words, P-809-1):** the LEAN on both halves. The sentence is her sketch made a sentence, verbatim: **"Books beyond your reach, if any, are not listed."** (the alternative recorded, not taken — a constant sentence cannot hint, and "if any" IS the honesty-by-humility construction she ratified). Placement: the ALWAYS-PRESENT key `beyond_reach` on the named tools' landed answers (never conditional); option (ii) recorded as the pure-but-silent alternative — rejected because the fixed words must TEACH partiality exactly where a hidden book kept the note and the bare answer would say nothing. The VX-764 nothing-stranded-bare-answer guard is SUPERSEDED by this (noted for the closeout's QUESTIONS entry — #258's P-771-12 disposition gains the cross-reference). `move_note_to_wing`'s raw unreadable **id** retires with the count (the id crosses the fence — worse than the count; say so in the record's framing for her bundle).
- **A-809-9 (batch 1, FORK F-3 — the titular ask):** **RULED IN — batch 1 builds it**, and it is the SHARED-BRAIN mint the coordinator assigned us (VX-840 re-seated into VX-828; both runs consume one predicate). Shape: the landed `remove_tag` answer adds the reach-scoped fact (the proposal's `tag_unused_in_reach: true|false` — whether any note this client can READ still wears the tag), ALWAYS present on a landed answer (the F-1 discipline), computed through the one reach rule, cost ∝ the tag's wearers with the first-readable-wearer short-circuit. **Include block applications where the block's note is readable** (the twin's predicate is "post and block alike"; the shared brain is the application-liveness predicate parameterized by scope — true-count for her surface, reach-filtered for the wire); if the survey shows block tags are invisible to every wire read, drop the wire's arm to post-only WITH the description saying so and the why in the batch record. The brain lives in VariorumCore (Queries/Domain — one home both consumers reach); **report its name, home file and exact signature in the batch record the moment it settles** — the orchestrator relays it to vx-828 and the coordinator. "The tag listing's rows" rides ONLY if a wire tag listing exists today (survey; none known — if none, record not-applicable). The description says the fact is reach-scoped and that deleting a tag is the author's, in Settings ▸ Tags.
- **A-809-11 (batch 1 close, FINDING F-5 — the fencing seat, P-809-8):** **option (a) rules, built at BATCH 3** (the intake neighborhood): an intake seat triggered by a WIRE applying act (a tag application or a star, on any road through the one application road — `apply_tag`, `duplicate_note` with_tags, `set_starred`, batch 3's `create_note` tags) **never fences the note — where the seat's landing would make it fenced (a Private book; the daily Journal), it BELLS instead** (an arrival is no membership, so no fence; her seat from Arrivals is her act). The why: F-5's leak is EXACTLY the topic channel her R-825 words named ("the book subject alone could tell you something"), and the mechanism is P-13nb-U4-16's mirror — an agent act must not silently move reach topology in either direction (a rule write must not expand it; an applying act must not shrink it and fence the agent's own subject). Un-tag and un-star stay non-events; her own acts are untouched; option (b) recorded, (c) rejected. **This provisionally changes product intake (a Private book's AI-tagged arrivals now wait at the door) — PROVISIONAL P-809-8, the bundle's lead line for her.** After the build the catalog's F-5 row flips from PENDING FINDING to a pure arm.
- **A-809-12 (batch 1 close, FINDING F-6 — the vocabulary):** **option (a) — a wing's tag vocabulary is wing-level reachable configuration, as built**; no change. The why: tags carry no fence of their own by design (the Private MARK, never a tag named "private"; no tag grant exists), the per-wing path uniqueness makes adoption forced (no twin road exists), and (b) would put a FALSE word on the wire ("made" of a tag the act adopted) — the door never lies. The thin residue (adopt-vs-mint reveals a path exists) is recorded; PROVISIONAL **P-809-9**, one bundle line, hers if she wants (b). The catalog's model already states (a).
- **A-809-13 (batch 1 close — the position-key residual, record-only):** the implementer's noted-never-seen residual (fractional positions minted between neighbors, hidden ones included) becomes a standing caution in batches 2–3's briefs: **no answer or cursor may be computed over raw rows or carry raw position keys** — every paging and ordering answer walks READABLE rows (the `list_notes` fix's rule), and no tool answers a position key. Verified per new tool in its catalog arms; nothing to build beyond that discipline.
- **A-809-10 (batch 1, FORK F-4 — VX-826's journal class, P-809-7):** **option (a)** — extend `DuplicateDay` to the journal class (an undated, untitled journal-profile source's copy takes the source's creation day as `entry_date`), keeping the ONE ratified mechanism and `DisplayTitle`'s no-write rule; (b) rejected (a derived title write breaks the no-denormalization rule), (c) rejected (R-826 says never today's). The notebook exposure is the SHIPPED kind (a dated ⌘J entry's duplicate already makes the same claim) — but it brushes VX-805's surfaces (VX-797 is redesigning several-entries-per-day), so the orchestrator flags the seam to the coordinator and vx-805 in one line; PROVISIONAL **P-809-7**, bundled. The exact-repro pin's expected verdict stands as the proposal frames it: green-on-current + red-with-VX-759-reverted ⇒ the agent's reported repro was fixed by VX-759 (their build predated it) — RECORDED as hollow-on-today's-tree, not re-fixed; the journal class is the remainder this ticket actually buys.

## Binding principles — the 13b constitution (copied per the architect-phase skill; byte-verbatim)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

*(The skill's application notes — P-1's routed-vocabulary scope, P-3's two surface kinds, layer placement, the overlay/sink delivery law — bind the same way.)*

## Code geography (the VX-771 survey, still current at kickoff)

The door: `Sources/VariorumMCP/` (tools `MCPToolCatalog.swift`, `MCPWriteTools*.swift`, `MCPReadTools*.swift`; server `MCPServerHost.swift`, `MCPSession.swift`; `MCPMintedBlocks.swift`, `MCPTextDigest.swift`; refusals `MCPWireRefusalCopy`) + `Sources/VariorumCore/Operations/Operations+MCP*.swift` + `Domain/MCPGrantRule*.swift` + `Persistence/MCPGrantSchema.swift`; the shim is the `variorum-mcp` executable target. Tests: `Tests/VariorumMCPTests/` (HEADLESS — no stage). The duplicate body: `Operations+Versions.swift` via `Operations+MCPDuplicate.swift`; `Domain/DuplicateDay` (VX-771). Lock road: `App/Variorum/Variorum/MacWillLock.swift` (ORDER LOAD-BEARING) + the host's stop roads. App faces: Settings ▸ Tags pane + the sidebar under `App/Variorum/`; the field guide seeds + `TutorialMCPChapterTests`. Each implementer re-surveys its own files; this map is a starting point, not a claim.

## The batch plan (five batches, strictly sequential, one fresh opus-implementer each)

### BATCH 1 — the pure-function law: VX-825 (lead) + VX-826

- **VX-825.** Four parts, in order:
  1. **Retire the counted arms** (red-on-old per arm): `remove_tag`'s `still_in_books_hidden_count`; `duplicate_note`'s `landed` hidden-counting arm ("a book not shared with you", fenced books among the counted); `move_note_to_wing`'s `left_books` hidden arm. In their place the FIXED SCOPE WORDS — ONE sentence used uniformly, byte-identical whether hidden things exist or not (her sketch: "books beyond your reach, if any, are not listed"); reach-NAMED parts stay byte-unchanged. The exact sentence: implementer proposes with the retirements, I rule, PROVISIONAL **P-809-1**. Tool descriptions updated to the new shape (they documented the counts).
  2. **Verify the name guard** (VX-259/VX-363 as shipped): rename_book/create_book/import_document-book-form count collisions only within read reach — verify in code, name the standing pins, add the two-store arms. No new behavior expected; a gap found = build to the ruling (collision with a hidden book creates the twin).
  3. **Design the ownership refusals' reach-pure shape** (R-825-sweep (b)) — the one place the law meets an act that CANNOT succeed (ownership is real). PROPOSE BEFORE BUILDING (the in-batch fork rule): enumerate every wire act that can hear `noteOwnedElsewhere`/`noteMemberedElsewhere` (add_note_to_book, duplicate_note's book form, the move/copy family — find them all), then 2–3 refusal shapes with their leak analysis. Orchestrator's lean to measure against: the refusal is ONE fixed sentence naming no book, no count, no kind — the single forced bit (refusal-where-success-would-be) is recorded as THE explicit narrow exception with its why; "answer the not-shared shape" (pretend the note is fine) and "just succeed" (break ownership) are both off the table. My ruling lands here as A-809-4 before the build; the shape is PROVISIONAL **P-809-2** for her ratify.
  4. **THE TWO-STORE CATALOG PIN** — the run's centerpiece evidence: one harness, two stores (one holding hidden things — Private notes/books, ungranted books and wings, a fenced daily Journal; one holding none), the SAME client with the SAME grants in both, every tool driven through EVERY answer arm INCLUDING refusals, each answer byte-identical across the stores — except the enumerated P-809-2 exception, asserted to be the ONLY difference. The catalog is a TABLE in this record (tool × arm × verdict) and a test that walks it; batches 2–3 add their tools' rows as they land.
  - Canon (drafted now, lands at closeout per the two-file rule): MCPSpec gains the general-law sentence + the retirements; AppSpec §12's summary and SurfaceContracts' Doors line touched only as far as they carried the counted shape.
- **VX-826 (Bug).** Trace first: VX-759/P-771-1 fixed `entry_date` but 2 of 7 copies still re-titled — find exactly which title class still derives "today" (the automatic date title's derivation at copy time vs `Domain/DuplicateDay`'s day). Fix to R-826: the copy reads the SOURCE's displayed title, never today's; the rule lands in the SHARED body (her two Duplicate doors + the wire + copy_note_to_wing — same reach as P-771-1/A-771-1; promote/diverge/forks are VX-845's, NOT this run's). Red-on-old pin on the exact repro (automatic date title + duplicate); byte-verbatim pin for typed-titled and dated classes; app-door twin pinned through the shared body.

### BATCH 2 — books on the wire: VX-807 + VX-813

*(Batch 1 addenda, binding here: build on batch 1's seams — the `beyond_reach` constant (`MCPBeyondReach.swift`) and the hidden-cause principle (`MCPHiddenCause.swift`, A-809-4) serve these tools too; EVERY new tool adds its arms to the two-store catalog (`MCPTwoStoreCatalogArms.swift` — the coverage test refuses an uncovered tool); A-809-13's discipline — answers and cursors walk READABLE rows only, no tool answers a raw position key; the socket-harness trap (traps section) governs every suite run; main moved to be17fb632 (VX-853, verify-pins' versions-equal guard) — merged in before the run's merge ask, not needed mid-batch.)*

- **VX-807.** `move_book_to_wing` wrapping `moveReadingToWing` whole (§9: members move whole, tags adopt by path, stay-behind memberships sever, finished/sealed ride whole, archived rides archived, pending arrivals dismissed, lands unshelved, the daily Journal refuses — all the op's own semantics; the op is NOT reach-gated, only the ANSWER is). **R-805-5 binds: the daily Journal's refusal is pinned AT THE TOOL LEVEL (the wire's own test, refusal shape asserted), never only through the op** — VX-805 is making the Journal movable for HER doors (VX-435) and the wire keeps refusing either way; the pin is the merge-order belt. Grant: A-809-2 (EDIT book + WRITE NEW destination wing, once grants spent together). Undo: her door has NO undo and `revivalWingScope` makes cross-wing replays no-ops — the implementer PROPOSES the undo story before building (wrap like move_note_to_wing's obsolete-quiet entry, or no entry with the answer saying the road back is moving it back — measure against MCPSpec's one-entry law and the save_commit exception); my ruling lands as A-809-5; PROVISIONAL **P-809-3**. Answer: what the app's confirm shows, REACH-SCOPED per R-807 — came-along count, severed memberships named only where the other book is readable, dismissed arrivals named/counted only where the waiting note is readable, the P-809-1 fixed scope words everywhere else. Gatherings: her door moves a gathering too? — mirror her door exactly (check `moveReadingToWing`'s kinds). Pins: state transitions (everything rides), refusals (daily Journal, missing wing, same wing), grant decisions, answer shapes, two-store rows.
- **VX-813.** `set_book_order` (`sort_field` ∈ manual · entry_date · created_at · last_touched · last_major_revision; `sort_dir`) at EDIT on the book; gatherings per her own doors' parity (R-VX184-1 — check what her book-settings sheet offers a gathering and mirror; a refusal her door doesn't have is wrong). Plus an `order` option on `create_book` AND `set_book_rule` (R-813's fuller paste) — same validation, same transaction, no second undo entry. No-op guarded (changed: false, nothing written — the VX-362 posture). Pins: transitions, schema-declared args, refusal parity with her door (finished/locked semantics — read the op's own guards, mirror exactly), two-store rows.

### BATCH 3 — note acts: VX-814 + VX-812 + the F-5 build (A-809-11, P-809-8)

*(The F-5 build lands here, FIRST: an intake seat triggered by a wire applying act never fences — a seat whose landing would fence the note (a Private book; the daily Journal) BELLS instead, on every road through the one application road; her acts untouched; un-tag/un-star stay non-events. Red-on-old pin through the catalog's F-5 row (it flips from PENDING FINDING to a pure arm) plus a state pin (the arrival row exists, no membership, the note unfenced, the client's next read serves). The batch 1 addenda in BATCH 2's note bind here too.)*

- **VX-814.** `tags` argument on `create_note` (all its forms that mint ONE note; the whole-book import is out of scope): applied through the ONE application road in the same transaction, adopt-or-mint by path (the capture microsyntax's exact rule), so living books hear the birth (seat or bell per `IntakeDecision` — existing semantics, assert not re-implement). Answer: `tag_ids` + `tags` per the VX-361 rule — argument tags in given order, then the outflow, deduped, listed once. One undo entry (the mint's own). Pins: in-transaction application, intake heard, microsyntax parity (same store rows as a `{#tag}` capture), answer order, two-store rows (a tag path colliding with a hidden wing's tag: per-wing vocabulary makes this a non-event — assert).
- **VX-812.** List forms ON THE EXISTING tools per R-812 — `delete_note`, `move_note_to_wing`, `apply_tag`/`remove_tag` take a list beside their single form (exact tool set: survey which single-note acts the sweep used; propose the final set before building). Semantics: each item its OWN operation in its own transaction, grant-checked and ⌥⌘Z-entried per the door's rules (her ⌥⌘Z walks items); per-item results in the answer (landed or the item's own worded refusal — NOTHING all-or-nothing; a cap of 200 stated in each description, the door's precedent); ONE receipt line naming the count (the app's bulk-bar words; the receipt's Open › behavior — propose: the last landed item, mirror the coalesced-run receipt's rule). The flush-first rule rides per item where the act meets a take. Plus **`replace_tag`**: tag A → tag B across ONE wing, across the client's REACH in that wing only (R-812's fence: hidden wearers untouched, unmentioned, uncounted) — enumerate the client's readable-at-EDIT notes wearing A in the wing, per note remove A + apply B through the one road (intake hears B as any application), B adopts-or-mints by path; answer counts the swept set only, with the P-809-1 scope words; cap and partial-refusal shape as the list forms. Undo: per-item entries (R-812's own text). Pins: per-item independence (one refusal doesn't halt the rest), reach fence (hidden wearer's row untouched — assert the row byte-identical after), intake consequences, receipt count, two-store rows.

### BATCH 4 — the server survives the lock: VX-818 (protection-adjacent; CastleRules read by the implementer IN FULL)

Today's contract (MCPSpec A-8): the lock stops the server and every connection; unlock restarts; the lock road writes close lines + the Activity end line inside `macWillLock`'s `endingConnections` step. The build REPLACES that posture for the LOCK (and any brief store-unavailable moment) while her switch, the library CLOSING (adopt/swap) and quit remain true stops:

- The server keeps LISTENING across the lock; existing connections and sessions SURVIVE; every call while locked answers ONE flat typed refusal before ANY store read (grants live in the store — no decision, no logging, no id resolution happens while locked; the sentence is checked at the call door ahead of everything, the pending-setup posture's precedent). The sentence leaks nothing (no titles, no counts) and is PROVISIONAL **P-809-4** (one flat line, e.g. "The library is locked — ask again once it's unlocked."; wording bundled for her).
- Unlock resumes serving on the SAME connections — no /mcp, no re-grant. **Consequence named plainly (the bundle + the record): while-connected grants now SURVIVE a lock→unlock cycle** (previously the lock ended every connection and with it every until-disconnect grant). This is the point of her ask (continuity) but it is a posture change at the protection seam — PROVISIONAL, flagged first in the bundle. `always` and `once` grants unchanged.
- New connections DURING the lock: the setup-key decision needs the store — the implementer PROPOSES the admit-or-hold shape before building (lean: accept the socket, answer initialize, and have every tool answer the locked sentence; nothing binds, nothing reads, the real key decision happens at unlock or the next call after it — measure against VX-258's waiting posture). A-809-6 rules it.
- The lock road's close lines and the Activity "library locked or closed" end line RETIRE for the lock (nothing ends); quit/switch-off/close roads keep theirs byte-unchanged. While locked nothing logs (the store is shut — the quit precedent); the description/docs say the posture. `MacWillLock.swift`'s step order: aim untouched (the `endingConnections` step becomes a no-op for the lock road or is bypassed — prefer the change INSIDE the door's own code); any order change is PROVISIONAL + bundle line.
- Suites: `MCPStopRoadsDoorTests` / `MacWillLockTests` / `MCPConnectionEndDoorTests` rewritten to the new posture (the lock is no longer a stop road); red-on-old pins: a call during lock answers the sentence (byte-flat, store untouched); the connection survives lock→unlock and the next call serves; until-disconnect grant alive after unlock; switch-off and quit unchanged; nothing written to Activity during lock.
- MCPSpec's A-8 line + the stop-roads paragraph get their closeout supersession draft (the two-file rule).

### BATCH 5 — the app faces + docs: VX-679 + VX-846 *(VX-840 re-seated into VX-828 — see the roster note; the shared unused-tags brain is batch 1's to mint and VX-828's to consume)*
- **VX-679.** The sidebar AI section, built EXACTLY to R-679's sitting rulings (quoted above; the ticket is the contract): its own section near the sidebar's bottom, ~3 rows reserved, scrolls within, GONE when empty; "From ‹client› · N"; row text = go there through the EXISTING offer-landing road (the re-read-the-place rule: a gone place says so where she pressed, opens nothing); the row's shared-with-AI symbol opens the details popover (client · when · act kind — a navigation ask, or a write and which operation · target). Session-scoped store on the app side (feeds: show_in_app asks + AI writes — the ⌥⌘O trail generalized; ⌥⌘O's own behavior byte-unchanged: still the LAST change). Mac-only. P1: the section renders its rows only, reads nothing while no client is approved (the shared icon's law). Evidence: view-model pins + a scripted screenshot walk if a stage window is cheap, else the pins + my hands-on walk at the closing window.
- **VX-846.** The docs tail, built BESIDE the run's own doc changes (batch 1 already rewrites remove_tag's description for the retired count; batch 1's close noted two more: the `add_note_to_book` and `move_note_to_wing` descriptions should say the hidden-cause fixed sentences exist — fold them in here): the guide's MCP chapter cards — decide-and-draft whether they name `create_gathering`, the remove_tag report (as THIS run reshapes it) and the old_str/new_str form; remove_tag's description's create_gathering pointer gains the lesser-grant alternative ("ask the author for a gathering"); `MCPSession.instructions` touched only within the 3,100 budget (prefer untouched — R-VX184-3). ALL wording PROVISIONAL **P-809-6**, drafted for her bundle (R-846: wording hers at the build). A guide-chapter edit stales the REAL store's seeded guide — the closeout notes the re-seed road (Help ▸ Restore Field Guide…, hers, behind the A1 rail).

### Then: the ladder (one, over the run's whole diff)

Fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing; findings repo-first (`notes/plans/fixes/vx-809-ladder-round1.md`); cross-model flow (the reviewer makes final calls; the implementer applies confirmed fixes red-on-old; round 2's fresh reviewer re-checks; cap three; a final round's fixes get my line-by-line check). Then the closing Mac-suite window (stage via the coordinator; suites covering every changed SOURCE file — grep tests for changed types; `TutorialWalkTests` ride; phone suites join if any `Shared/` file lands), closeout, PR `VX-809: …`, coordinator-serialized merge.

## Acceptance units & evidence

One batch = one acceptance unit = one implementer session. Evidence by kind: the TWO-STORE CATALOG pin + per-arm red-on-old retirement pins (VX-825); red-on-old on the exact repro + shared-body twins (VX-826); wire state-transition + answer-shape + grant-decision pins (VX-807, 812, 813, 814); the lock-posture pins over the rewritten stop-road suites (VX-818); the shared-predicate + door pins and the view-model pins (VX-840, VX-679); the docs pins + budget pin (VX-846). The run closes on the ladder + the closing Mac window + my hands-on walk of the faces, never a pin alone.

## Environment traps (every batch brief carries these verbatim)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store instances by STORE, never quit/kill one; no Release builds or /Applications refreshes while one lives.
- Headless `swift build` / `swift test` on the core package: NO stage, runs freely. EVERY `xcodebuild test` (Mac app or sim): a HELD stage claim via nov4coordinator. Mac tests from `App/Variorum/`, suite-level `-only-testing`, confirm the "Test run with N tests" line; zsh `pipestatus`; never a custom build configuration.
- Core `swift build` prints 7 EXPECTED "dependency not used by any target" warnings (the VX-781 pin belt's accepted cost); `PinBeltTests` rides every `swift test`. A reused DerivedData re-resolves to the committed pins on the next build.
- **The MCP socket-harness suites are a CROSS-WORKTREE shared resource even in headless `swift test`** (the coordinator's wave-1 trap, 2026-11-05; VX-850's neighborhood — vx-828's core run collided with ours: four socket suites "got no answer to its initialize", 17/17 green re-run alone). (1) A socket-harness RED during any concurrent run is NO VERDICT — re-run those suites ALONE before calling it, red and green-on-old claims alike. (2) A MERGE-GATING or RED-ON-OLD run of the MCP socket suites is announced THROUGH THE ORCHESTRATOR to the coordinator first, one line, so two never overlap (not a stage claim — a short turn).
- Swift Testing's pass line COUNTS skipped tests — read the `skipped:` lines before claiming a gated suite ran.
- Dev store content is the agents' to manage; the stage/account/Castle-credential fences stand. The Debug app NEVER signs into her real account. Castle values only from `~/.variorum/dev-castle.env`, never invented, never committed.
- Commit per piece, push after each (NO attribution trailers); LIVE STATUS from the first commit; synchronous foreground waits only (poll with `grep -q … && break; sleep 5` loops, never tail-f-grep); never `git add -A` (pathspec adds); never spawn subagents from an implementer session except ONE read-only Sonnet for EXTERNAL facts.
- Screenshots in gitignored dirs; never `git checkout` over uncommitted work; commit before any behavioral revert.

## LIVE STATUS ledger (flipped per piece, same commit)

| # | Item | Status |
|---|---|---|
| 1 | BATCH 1 — VX-825 + VX-826 | **DONE 2026-11-05** (head `54831417f`; the BATCH 1 RECORD below; orchestrator's drill: the catalog + hidden-cause + reach-pure suites alone, "✔ Test run with 15 tests in 3 suites passed"; F-5/F-6 ruled A-809-11/-12 — the F-5 build rides batch 3) |
| 2 | BATCH 2 — VX-807 + VX-813 | NOT STARTED |
| 3 | BATCH 3 — VX-814 + VX-812 | NOT STARTED |
| 4 | BATCH 4 — VX-818 | NOT STARTED |
| 5 | BATCH 5 — VX-679 + VX-846 (VX-840 re-seated into VX-828) | NOT STARTED |
| 6 | The ladder | NOT STARTED |
| 7 | Closing Mac window + walk | NOT STARTED |
| 8 | Closeout (canon, tickets, handoff, merge) | NOT STARTED |

## HELD FOR HER (the bundle — grows through the run)

- P-809-1 (the fixed scope words — ruled A-809-8: her sketch verbatim, "Books beyond your reach, if any, are not listed.", the always-present `beyond_reach` key) · P-809-2 (the ownership refusals — ruled A-809-4: the readable-entity principle; the hidden-cause fixed sentence's wording; **S-1/#218 standing within it and S-2 folding in ride this entry so she sees the exception family whole**) · P-809-3 (move_book_to_wing's undo story) · P-809-4 (the locked sentence + the while-connected-grants-survive-the-lock consequence) · ~~P-809-5~~ RETIRED (VX-840 re-seated; the Trash lean rides its ticket for VX-828) · P-809-6 (the docs wording) · P-809-7 (the journal-class DuplicateDay extension — ruled A-809-10; brushes VX-805's several-entries-per-day work, seam flagged) · **P-809-8 (THE BUNDLE'S LEAD LINE — A-809-11: an intake seat a wire applying act triggers never fences; a Private book's or the daily Journal's seat BELLS instead. This provisionally changes product intake on her own books — F-5's leak was exactly her R-825 topic channel, and the fix mirrors her rule-write precedent; option (b), accept-as-exception, recorded)** · P-809-9 (A-809-12: the tag vocabulary stays wing-level reachable state; adopt-vs-mint's thin residue recorded, option (b) hers if wanted) — all built the lean way, hers to ratify.
- RIDER OFFER (the kickoff duty — open Low/Medium in this run's areas whose code this run opens): **VX-777** (a stale start's fresh.stop() speaks switch-off words to a replaced host's connections — exactly VX-818's file) · **VX-775** (an Activity-write failure after a landed act answers the client an error — the wire's act path) · **VX-776** (store read failure inside MCPSession's SDK handlers unworded). Not adopted without her word.
- The field guide re-seed of her REAL store if VX-846 changes chapter content (her hands, A1 rail).

---

## BATCH 1 RECORD — the pure-function law (VX-825) + the duplicate's date title (VX-826)

**NOT DONE in this batch (first, as the protocol asks):** FINDING F-5 (an AI-applied tag seating a note into a hidden Private book, fencing it — the act's answer is pure, its consequence on reach is not) is NOT built — options below, awaiting a ruling; the catalog pins today's behavior as a PENDING FINDING row. FINDING F-6 (is the tag vocabulary reachable state?) is a modeling question, NOT built (lean: as built). Canon NOT applied (the closeout's — the CANON DRAFT below). QUESTIONS NOT touched (merge moment). No walk/stage run (headless batch). The add_note_to_book / move_note_to_wing descriptions do not yet say the hidden-cause sentence (VX-846's docs tail may).

**Implementer:** opus-implementer (fresh, batch 1), 2026-11-05, worktree `~/dev/variorum-vx-809`. Headless only (`swift test`), no stage claim held. **No revert is in flight.** **No `App/Variorum/Shared/` file is in this batch's diff (none expected).**

### LIVE STATUS (flipped per piece, same commit)

| # | Piece | Status |
|---|---|---|
| B1-0 | Preflight read (record whole · MCPSpec in full · QUESTIONS #258 · SurfaceContracts Doors · VX-771 FOR A LATER READER · SessionResiliencyProtocol) + the code survey + VX-825/826 ticket threads | DONE |
| B1-1 | FORK F-1 (P-809-1) — the fixed scope sentence + its per-tool placement | RULED A-809-8 (the lean, both halves) — wired (`MCPBeyondReach.swift`) |
| B1-2 | Retire `remove_tag`'s `still_in_books_hidden_count` | DONE (`fc45ea23e`) — pins RED on `56a3a7334`'s tree (logged: the two stores' answers differed by the count / the key's presence), GREEN after |
| B1-3 | Retire `duplicate_note`'s `landed` counted arm | DONE (`fc45ea23e`) — pins RED on old (the hidden store's `landed` read "…, and a book not shared with you, which collects one of its tags"), GREEN after |
| B1-4 | Retire `move_note_to_wing`'s `left_books` hidden arm | DONE (`fc45ea23e`) — pin RED on old (`{"book_id":"F0000000-…"}` crossed), GREEN after |
| B1-5 | The three tool descriptions to the new shape | DONE (`fc45ea23e`) — pin RED on old, GREEN after |
| B1-6 | Name guard verify (VX-259 / VX-363 / create_gathering) | DONE — VERIFIED IN CODE, no build: all four wire roads pass `readableBooks(clientName)` (`Operations.BookNameReach` — a colliding reading counts only while this client can READ it): `import_document`'s book form (`MCPWriteTools.swift:533`), `create_book` (`:585`), `create_gathering` (`MCPWriteTools+CreateGathering.swift:66`), `rename_book` incl. gatherings (`MCPWriteTools+LibraryEdits.swift:395`). Standing pins: `MCPBookNameReachServerTests` (rename · create_book · the import book form); `create_gathering` had none — its two-store arm is now the catalog's. Two-store arms (each name worn by a PRIVATE book in Studio in A only): all four LAND, byte-identical across the stores |
| B1-7 | FORK F-2 (P-809-2) — the ownership refusals (+ S-2 folds in; S-1/#218 stands) | DONE (`1805c2d50`) — `MCPHiddenCause.swift` (the reachable verdict; the two fixed sentences; a readable claimant's refusal RE-KEYED to readable claimants only, so no unreadable id rides into any host's words); `add_note_to_book` + `move_note_to_wing`'s frozen arm wired. `MCPHiddenCauseServerTests` 5 tests (6 cases) RED on the pre-build call sites (logged: every arm carried `F0000000-…` — the hidden owner/claimant/frozen book's id), GREEN after; one justified edit (`MCPWingMoveServerTests` — the unreadable frozen book now says the move's fixed sentence). Note: no "readable plain book beside a hidden owner" arm exists locally (ownership is exclusive — only a sync residue could make one) |
| B1-8 | THE TWO-STORE CATALOG PIN | DONE (`728eda7a7`) — `MCPTwoStoreCatalogServerTests` + `MCPTwoStoreCatalogArms.swift`: 181 arms over all 68 tools (`theWalkCoversEveryDeclaredTool`), three stores (A hidden · B, C none — B==C is the control), GREEN: 176 IDENTICAL · 4 EXCEPTIONS (A-809-4) · 1 PENDING FINDING (F-5, below). It FOUND two more leaks, fixed here (B1-12) |
| B1-9 | VX-826 — the exact-repro pin, the journal class's pins + fix (F-4, A-809-10) | DONE (`479986cde`; pins `0e8e00830`). (1) THE EXACT REPRO is HOLLOW on today's tree: `MCPDuplicateDateTitleServerTests` GREEN ×3 forms on `0e8e00830`; with VX-759's `keepingNamedDay` forced off (the named revert, run then `git checkout --`'d — the file restored, `git diff` empty) it went RED ×3 at the copy's `read_note` title ⇒ the agent's 2-of-7 was VX-759's class on a build without VX-759 — recorded fixed-by-VX-759, not re-fixed. (2) THE JOURNAL CLASS (the remainder): `DuplicateDateTitleTests` RED on `0e8e00830` (4 cases: her Duplicate with/without Tags, Copy to Wing's copyPost and bare-row paths — the copy named for today), GREEN after the fix — `DuplicateDay`'s guard drops `profile != .journal` (P-809-7; the edit kept to the guard line + its one doc bullet, `profile` left on the signature unread — the VX-845 seam, coordinator's request). Residuals byte-verbatim and GREEN on both sides: typed-titled undated (journal + generic) stays undated, dated journal verbatim, saved version date-cleared (V3). Justified edits: `DuplicateKeepsItsDayTests` — the rule table's journal arm, and the two "journal stays undated" pins re-pointed to the new class (their canonical-entry asserts dropped — VX-797 owns that seam). Duplicate/date family: 41 + 96 tests green |
| B1-10 | FORK F-3 — VX-825's titular ask: `tag_unused_in_reach` + THE SHARED BRAIN | RULED IN A-809-9 — DONE (`5279ec16a`): the brain (signature below), the wire arm, the description; pins GREEN (`TagUsageQueriesTests` 8, `MCPReachPureAnswersServerTests` +4) |
| B1-11 | Self-assessment + test counts | DONE (this commit) — the SELF-ASSESSMENT section below |
| B1-12 | Two leaks the catalog found, fixed (the law is ruled; no new behavior chosen): (a) `list_notes`' `book_ids` listed EVERY live book holding a note — unreadable ones' ids crossed; now readable books only. (b) `list_notes` paged on RAW rows: a hidden row shortened a page, and `next_cursor` (base64 of the last raw row) carried a HIDDEN note's id; a gathering cursor's key was its assembly index, counting hidden notes. Now the page is walked over READABLE rows (`MCPReadTools.listNotes`), the cursor names the last KEPT row, a gathering cursor's key is the readable ordinal | DONE (`728eda7a7`) — RED ON OLD VERIFIED: `MCPReadTools.swift` reverted to `1805c2d50`'s bytes (the named revert, on the committed tree), the catalog went RED on 6 `list_notes` arms (12 issues: each varied AND carried a hidden id — in `book_ids` or inside the base64 `next_cursor`), then `git checkout --` restored it (`git status` clean) and the catalog is GREEN |

### THE SHARED UNUSED-TAGS BRAIN — settled (A-809-9; for the relay to vx-828 / VX-840)

- **Name and home:** `Queries.tagSubtreeIsWorn` in **`Sources/VariorumCore/Queries/TagUsageQueries.swift`** (VariorumCore — reachable from the app and the door alike).
- **Exact signature:**
  ```swift
  public enum TagWearerScope {                       // nested: Queries.TagWearerScope
      case library(countingTrashRevivable: Bool)     // her surface: every live wearer, snippets included
      case reach(readable: ([String]) throws -> Set<String>)   // the wire: batches of note ids in, the readable ones out
  }
  public static func tagSubtreeIsWorn(_ db: Database, tagID: String, scope: TagWearerScope) throws -> Bool
  ```
- **Semantics:** WORN = the tag OR any live tag under it (its subtree by materialized path — `deleteTag` deletes the subtree) has a live application on a wearer the scope counts: a live `post_tag` on a live post; a live `block_tag` on a live block — on `.reach` only through the live NOTE that places the block (a snippet / pool block or an unplaced block counts for no client). `.library(countingTrashRevivable: true)` ALSO counts a tombstoned application on the exact stamp of its tombstoned, not-yet-purged wearer (the cascade victims `restoreContainer`/`restoreBlock` revive) — **VX-840's A-809-1 Trash lean is theirs to pass (true = "Trash wearers keep it in use")**; `false` = live wearers only. A missing/tombstoned tag is worn by nothing. "Unused" for the sweep = `!tagSubtreeIsWorn(db, tagID:, scope: .library(...))`, which is subtree-honest by construction. Cost ∝ the subtree's applications; `.reach` pages 200 note ids at a time and stops at the first readable wearer. The wire's consumer: `MCPWriteTools.tagUnusedInReach` (`MCPWriteTools+RemoveTag.swift`) — `.reach` with `MCPGrantAuthority.decide(standing, note:, rung: .read, consumes: false)` over `Queries.mcpNoteFacts`.
- **Block tags ARE wire-visible** (the survey A-809-9 asked for): the wire's `search` runs at the PASSAGE level, whose `#tag` filter matches block-level tags (`SearchComposer.tagSubtree`, `.passage` — "`d.block_id IN (… block_tag …)`"), so the wire arm includes block applications on readable notes, as the ruling's default said.
- **A wire tag listing: NOT APPLICABLE** — no tool lists tags today (the 68-tool catalog has none; tags reach the wire only as a note's header paths and as answer echoes).
- **For a batch caller** (the sweep over a wing's tags): call it per tag over `Queries.allTags(db, wingID:)` — ∝ the wing's tags × their applications, the sweep's own scale; a batched statement can be added BESIDE it in this file if their pane needs one (same SQL fragments), never a second predicate.


### THE CATALOG (B1-8) — tool × arm × verdict (generated by the pin, `VX825_CATALOG_TABLE=<path> swift test --filter MCPTwoStoreCatalogServerTests`)

**Method.** Three stores built through the same calls in the same order: **A** holds the hidden things (an owned Vault claiming a reachable note; a living "Secret board" collecting #board and holding two reachable notes; a finished book holding a reachable note; a PRIVATE "Diary" in Studio collecting #idea; four PRIVATE books named as the client's later mints; a whole ungranted wing "Attic" with a book and a note; the daily Journal and a ⌘J entry; PRIVATE members of four reachable books, one FIRST in its order; a hidden chapter; an ungranted Home note — with a block, take, comment, commit and lens — wearing a vocabulary tag no readable note wears; a PRIVATE Studio note a gathering's rule matches). **B** and **C** hold none (B==C is the harness's determinism CONTROL). Hidden rows are minted by a separate operations value (`F0000000-…` ids, its own clock and jitter), and the harness's jitter is SEEDED (`ServerHarness(seed:)`), so every reachable id/stamp/position aligns. The SAME client (`claude-code`: EDIT on books Shared · Capped · Capped too · Doomed, EDIT on the Studio wing, EDIT on two notes, READ on one) walks 181 arms; A passes hidden ids where B and C pass the same strings naming nothing. Ids the walk MINTS compare as identities (per-arm first-appearance order): production ids are random UUIDv4, so the harness's incrementing counter would otherwise turn a row the client never sees (a hidden book seating a copy) into a shifted id. A crossing check (incl. inside base64 cursors) fails any arm whose A answer carries a hidden id B's does not.

**Exceptions (A-809-4's one class — each asserted to answer exactly the ruled words):** `add_note_to_book` on a note an unreadable owned book claims → P-809-2's sentence · `move_note_to_wing` on a note an unreadable finished book holds → the move's sentence (S-2) · `create_note` / `add_note_to_book` into a capped book a Private member fills → her capacity words about the READABLE target (S-1, #218 stands).

**PENDING FINDING F-5** — see below; the row asserts today's behavior exactly so any change is seen.

| Arm | Answer (A) | Verdict |
|---|---|---|
| list_books | landed | IDENTICAL |
| list_books · include_archived | landed | IDENTICAL |
| list_notes | landed | IDENTICAL |
| list_notes · a shared book with a Private member | landed | IDENTICAL |
| list_notes · a shared book, paged | landed | IDENTICAL |
| list_notes · the capped book | landed | IDENTICAL |
| list_notes · a gathering (a Private note matches its rule) | landed | IDENTICAL |
| list_notes · a gathering, paged | landed | IDENTICAL |
| list_notes · everything shared, paged | landed | IDENTICAL |
| list_notes · the Studio wing, paged | landed | IDENTICAL |
| list_notes · the Studio wing (a Private note in its Pool) | landed | IDENTICAL |
| list_notes · Home (no wing grant) | refused | IDENTICAL |
| list_notes · a hidden wing | refused | IDENTICAL |
| list_notes · a hidden owned book | refused | IDENTICAL |
| list_notes · a hidden Private book | refused | IDENTICAL |
| read_note · card with ids (a hidden board holds it) | landed | IDENTICAL |
| read_note · card, text | landed | IDENTICAL |
| read_note · card, everything | landed | IDENTICAL |
| read_note · a note a hidden owned book claims | landed | IDENTICAL |
| read_note · a note a hidden finished book holds | landed | IDENTICAL |
| read_note · a hidden note | refused | IDENTICAL |
| read_note · the daily Journal's entry | refused | IDENTICAL |
| read_note · a Private member of a shared book | refused | IDENTICAL |
| read_note · a hidden lens on card | refused | IDENTICAL |
| search · a word hidden notes hold | landed | IDENTICAL |
| search · words | landed | IDENTICAL |
| search · #board | landed | IDENTICAL |
| search · #secret-topic | landed | IDENTICAL |
| search · in the shared book | landed | IDENTICAL |
| search · in a hidden book | refused | IDENTICAL |
| search · in a hidden note | refused | IDENTICAL |
| export_note · card | landed | IDENTICAL |
| export_note · a hidden note | refused | IDENTICAL |
| list_wings | landed | IDENTICAL |
| show_in_app · card | landed | IDENTICAL |
| show_in_app · a hidden note | refused | IDENTICAL |
| show_in_app · a hidden wing | refused | IDENTICAL |
| show_in_app · a hidden book | refused | IDENTICAL |
| add_take · card | landed | IDENTICAL |
| add_take · a hidden block | refused | IDENTICAL |
| add_comment · card | landed | IDENTICAL |
| add_comment · a hidden block | refused | IDENTICAL |
| add_takes · card | landed | IDENTICAL |
| add_takes · a hidden block inside a shared note's batch | refused | IDENTICAL |
| add_comments · card | landed | IDENTICAL |
| add_comments · a hidden note | refused | IDENTICAL |
| delete_comment · its own | landed | IDENTICAL |
| delete_comment · a hidden comment | refused | IDENTICAL |
| save_lens · card, pinned | landed | IDENTICAL |
| save_lens · a hidden note | refused | IDENTICAL |
| create_note · in Studio | landed | IDENTICAL |
| create_note · into the shared book | landed | IDENTICAL |
| create_note · a hidden wing | refused | IDENTICAL |
| create_note · a hidden book | refused | IDENTICAL |
| create_note · a hidden chapter of a shared book | refused | IDENTICAL |
| import_document · in Studio | landed | IDENTICAL |
| import_document · a book named as a hidden one is | landed | IDENTICAL |
| apply_tag · card, a new path | landed | IDENTICAL |
| apply_tag · a hidden note | refused | IDENTICAL |
| create_book · a name a hidden book wears | landed | IDENTICAL |
| create_book · a hidden wing | refused | IDENTICAL |
| create_gathering · a name a hidden book wears | landed | IDENTICAL |
| create_gathering · a hidden wing | refused | IDENTICAL |
| add_note_to_book · a hidden note | refused | IDENTICAL |
| add_note_to_book · into a hidden book | refused | IDENTICAL |
| add_note_to_book · already a member | refused | IDENTICAL |
| create_section · the shared book | landed | IDENTICAL |
| create_section · a hidden book | refused | IDENTICAL |
| save_version · card | landed | IDENTICAL |
| save_version · a hidden note | refused | IDENTICAL |
| file_note_in_chapter · card | landed | IDENTICAL |
| file_note_in_chapter · a hidden chapter | refused | IDENTICAL |
| set_book_rule · the shared book collects #board | landed | IDENTICAL |
| set_book_rule · a hidden book | refused | IDENTICAL |
| link_versions · card and second | landed | IDENTICAL |
| link_versions · with a hidden note | refused | IDENTICAL |
| insert_blocks · card's end | landed | IDENTICAL |
| insert_blocks · after a hidden block | refused | IDENTICAL |
| insert_blocks · a hidden note | refused | IDENTICAL |
| duplicate_note · card into the shared book (a hidden board collects its tag) | landed | IDENTICAL |
| duplicate_note · a hidden note | refused | IDENTICAL |
| duplicate_note · into a hidden book | refused | IDENTICAL |
| copy_note_to_wing · card to Studio | landed | IDENTICAL |
| copy_note_to_wing · to a hidden wing | refused | IDENTICAL |
| copy_note_to_wing · a hidden note | refused | IDENTICAL |
| edit_take · card | landed | IDENTICAL |
| edit_take · a hidden take | refused | IDENTICAL |
| divide_block · work | landed | IDENTICAL |
| divide_block · a hidden block | refused | IDENTICAL |
| merge_blocks · a hidden block | refused | IDENTICAL |
| move_block · work's last to its start | landed | IDENTICAL |
| move_block · a hidden block | refused | IDENTICAL |
| set_block_name · card | landed | IDENTICAL |
| set_block_name · a hidden block | refused | IDENTICAL |
| delete_block · work's last | landed | IDENTICAL |
| put_back · work's block | landed | IDENTICAL |
| delete_block · a hidden block | refused | IDENTICAL |
| put_back · a hidden block | refused | IDENTICAL |
| set_entry_date · card | landed | IDENTICAL |
| set_entry_date · a hidden note | refused | IDENTICAL |
| move_note_to_wing · mover (a hidden board held it too) | landed | IDENTICAL |
| move_note_to_wing · to a hidden wing | refused | IDENTICAL |
| move_note_to_wing · a hidden note | refused | IDENTICAL |
| save_commit · card | landed | IDENTICAL |
| save_commit · a hidden take | refused | IDENTICAL |
| choose_take · card | landed | IDENTICAL |
| choose_take · a hidden take | refused | IDENTICAL |
| adopt_lens · card's lens | landed | IDENTICAL |
| adopt_lens · a hidden lens | refused | IDENTICAL |
| remove_tag · card #board (a hidden board holds it) | landed | IDENTICAL |
| remove_tag · not worn | refused | IDENTICAL |
| remove_tag · a hidden note | refused | IDENTICAL |
| edit_comment · card's | landed | IDENTICAL |
| edit_comment · a hidden comment | refused | IDENTICAL |
| restore_comment · its own | landed | IDENTICAL |
| restore_comment · a hidden comment | refused | IDENTICAL |
| set_take_label · card | landed | IDENTICAL |
| set_take_label · a hidden take | refused | IDENTICAL |
| lock_take · card | landed | IDENTICAL |
| unlock_take · card | landed | IDENTICAL |
| lock_take · a hidden take | refused | IDENTICAL |
| unlock_take · a hidden take | refused | IDENTICAL |
| archive_take · card | landed | IDENTICAL |
| unarchive_take · card | landed | IDENTICAL |
| archive_take · a hidden take | refused | IDENTICAL |
| unarchive_take · a hidden take | refused | IDENTICAL |
| delete_take · its own take | landed | IDENTICAL |
| delete_take · a hidden take | refused | IDENTICAL |
| restore_commit · card | landed | IDENTICAL |
| restore_commit · a hidden commit | refused | IDENTICAL |
| rename_commit · card | landed | IDENTICAL |
| rename_commit · a hidden commit | refused | IDENTICAL |
| rename_note · card | landed | IDENTICAL |
| rename_note · a hidden note | refused | IDENTICAL |
| delete_lens · its own | landed | IDENTICAL |
| delete_lens · a hidden lens | refused | IDENTICAL |
| rename_book · toward a name a hidden book wears | landed | IDENTICAL |
| rename_book · a hidden book | refused | IDENTICAL |
| move_note_in_book · second to the start | landed | IDENTICAL |
| move_note_in_book · after a hidden member | refused | IDENTICAL |
| rename_chapter · Part one | landed | IDENTICAL |
| rename_chapter · a hidden chapter | refused | IDENTICAL |
| move_chapter · Part 1 to the end | landed | IDENTICAL |
| move_chapter · a hidden chapter | refused | IDENTICAL |
| delete_chapter · Part two | landed | IDENTICAL |
| delete_chapter · a hidden chapter | refused | IDENTICAL |
| remove_note_from_book · second | landed | IDENTICAL |
| remove_note_from_book · a hidden member | refused | IDENTICAL |
| set_starred · card | landed | IDENTICAL |
| set_starred · the shared book | landed | IDENTICAL |
| set_starred · a hidden note | refused | IDENTICAL |
| set_starred · a hidden book | refused | IDENTICAL |
| archive_note · mover | landed | IDENTICAL |
| unarchive_note · mover | landed | IDENTICAL |
| archive_note · a hidden note | refused | IDENTICAL |
| unarchive_note · a hidden note | refused | IDENTICAL |
| finish_book · the shared book (a Private member inside) | landed | IDENTICAL |
| reopen_book · the shared book | landed | IDENTICAL |
| finish_book · a hidden book | refused | IDENTICAL |
| reopen_book · a hidden book | refused | IDENTICAL |
| archive_book · a book with a Private member | landed | IDENTICAL |
| unarchive_book · that book | landed | IDENTICAL |
| archive_book · a hidden book | refused | IDENTICAL |
| unarchive_book · a hidden book | refused | IDENTICAL |
| list_my_activity | landed | IDENTICAL |
| list_books · after the acts | landed | IDENTICAL |
| list_notes · the shared book after the acts | landed | IDENTICAL |
| list_wings · after the acts | landed | IDENTICAL |
| delete_note · mover | landed | IDENTICAL |
| delete_note · a hidden note | refused | IDENTICAL |
| delete_book · a book with a Private member | landed | IDENTICAL |
| delete_book · a hidden book | refused | IDENTICAL |
| create_note · a capped book (a Private member fills it) | A refused / B landed | EXCEPTION (A-809-4 S-1 — fullness of the readable target; #218 stands) |
| apply_tag · card, a path only a hidden note wears | landed | IDENTICAL |
| apply_tag · a studio note, a Private book's tag | landed | IDENTICAL |
| add_note_to_book · a note an unreadable owned book claims | A refused / B landed | EXCEPTION (A-809-4 / P-809-2 — the owner is beyond reach) |
| add_note_to_book · the capped book (a Private member fills it) | A refused / B landed | EXCEPTION (A-809-4 S-1 — fullness of the readable target; #218 stands) |
| duplicate_note · seed in Studio (a Private book collects its tag) | landed | IDENTICAL |
| read_note · the seed's copy (a Private book took it in) | A refused / B landed | PENDING FINDING (F-5 — an AI-applied tag seats the note into a hidden Private book, fencing it) |
| move_note_to_wing · a note an unreadable finished book holds | A refused / B landed | EXCEPTION (A-809-4 S-2 — the frozen book is beyond reach) |
| remove_tag · card #secret-topic (only a hidden note wears it after) | landed | IDENTICAL |

### FINDING F-5 (for the orchestrator — NOT built): an AI act that applies a tag can move the note out of the client's reach, because a hidden PRIVATE book collects that tag

**Mechanism (traced + pinned by the catalog's tail row):** intake is event-driven — an applying act (a tag application, a star) is heard by every living book whose rule collects it, and a book that joins quietly SEATS the note (`IntakeDecision`). The fence's Private leg holds for "a live member of a live reading carrying the Private mark" (`MCPGrantQueries.mcpNoteFacts`). So when a WIRE act applies a tag — `duplicate_note` with_tags (the catalog's arm: the copy of a Studio note lands, then is seated in the hidden PRIVATE "Diary" collecting #idea), `apply_tag`, `set_starred`, and from batch 3 `create_note` tags — and a Private book collects that tag, the note becomes FENCED: the act's own answer is pure (byte-identical across the stores), but the client's NEXT read of that note answers not-shared, where a store without the Private book reads it. What leaks: the bit "a Private book collects tag X" — the topic channel her R-825 question named ("the book subject alone could tell you something").

**Options:**
- **(a) LEAN — an intake seat a WIRE act triggers never FENCES the note: where the seat would make it fenced (a Private book, or the daily Journal's membership leg), it BELLS instead** (an arrival is no membership, so no fence; her own seat from Arrivals is her act — the same as her marking the note Private). The precedent is P-13nb-U4-16 ("an agent-written rule bells, never backfill-seats" — a rule write must not move the writer's own reach); this is its mirror for applications. Cost: her Private book's auto-intake from AI-applied tags waits at Arrivals. Touches `Operations` intake (an op every AI write rides) — a seam beyond this batch's door files; the author's call (product behavior).
- **(b) accept it as the law's second recorded exception** (the act's CONSEQUENCE on reach, not its answer) — her Private mark wins ties by design; the topic bit leaks.
- **(c) refuse the applying act where the seat would fence the note** (a fixed sentence) — the same bit leaks, earlier, and the act is lost; rejected.

### FINDING F-6 (for the orchestrator — a modeling question, NOT built): is a wing's TAG VOCABULARY reachable state?

The catalog models the vocabulary as reachable (the tag `secret-topic` exists in BOTH stores; in A only a hidden note wears it), and under that model every arm is pure (`apply_tag` adopts the same tag; `remove_tag`'s `tag_unused_in_reach` answers `true` in both). But a tag path usually EXISTS because some note was tagged, and several answers say adopt-vs-mint explicitly — `move_note_to_wing`/`copy_note_to_wing`'s `tags: {adopted, made}`, `create_gathering`'s `minted_tags`, `set_book_rule`'s minted tags (and batch 3's `create_note` tags) — so a path worn only by hidden notes (e.g. a Private note's "therapy") is observable as "adopted" where a store without that note "made" it. **Options:** (a) the vocabulary is wing-level configuration, reachable to the wing's clients — as built, no change; (b) a tag counts as reachable only while a note (or block) the client can read wears it — adopt-vs-mint answers would then report such a tag as made (the act still adopts — no twin). Lean (a) for now (tags have no fence of their own and no grant; (b) makes the answer say "made" of a tag that was adopted); hers if (b).

### CANON DRAFT (for the closeout — the two-file rule; NOT applied to canon by this batch)

- **MCPSpec, beside "The fence" (the general law):** "**Every answer is a pure function of the client's reachable state (VX-825 — her R-825; the record `notes/plans/fixes/vx-809-mcp-door-ergonomics.md`):** nothing on the wire varies with what the client cannot reach, refusals included — pinned by the two-store catalog (every tool's arms; an answer must not differ between a store where hidden things exist and one where none do). An answer listing the books an act touched names only books the client can read and carries `beyond_reach`, one fixed sentence ("Books beyond your reach, if any, are not listed." — P-809-1); the counted-not-named class is retired. The ONE recorded exception class (A-809-4, P-809-2): a refusal whose cause is a fact of an UNREADABLE entity speaks one fixed sentence per act family — `add_note_to_book`'s ownership consult, `move_note_to_wing`'s finished or sealed holder — while a refusal a READABLE entity explains keeps her words, keyed to the readable entities alone (capacity is the add-target's own fact: QUESTIONS #218 stands). `list_notes` lists a note's readable books only and pages over readable rows."
- **MCPSpec, `remove_tag`'s clause** — replace "`still_in_books_hidden_count` counts the rest, fenced books among them; nothing stranded answers byte-unchanged" with: "`still_in_books` is ALWAYS present (readable books only, `[]` when none) beside `beyond_reach`, and `tag_unused_in_reach` says whether no note the client can read wears the tag or a tag under it, on the note or a block it places (the shared brain `Queries.tagSubtreeIsWorn`, VX-840's too) — so the client can suggest the deletion, which stays hers."
- **MCPSpec, `duplicate_note`'s `landed` clause (VX-383's)** — replace "named where the client can read it, counted as "a book not shared with you" where it can't, fenced books among the counted" with "named only where the client can read it, beside `beyond_reach`".
- **AppSpec §12 / SurfaceContracts' Doors line:** neither carried the counted shape — no change owed there; the Doors line could gain the law's one sentence ("every answer is a pure function of the client's reachable state") at the closeout's judgment.
- **The QUESTIONS #258 cross-reference (A-809-8's note):** P-771-12's "nothing stranded answers byte-unchanged" guard is SUPERSEDED by the always-present keys.

### SELF-ASSESSMENT (B1-11)

**What landed (commits on `vx-809-mcp-door-ergonomics`):** `56a3a7334` record + forks · `1c210323f` retirement pins RED · `fc45ea23e` the three counted arms retire (A-809-8) · `5279ec16a` the shared brain + `tag_unused_in_reach` (A-809-9) · `1805c2d50` the hidden-cause refusals (A-809-4) · `0e8e00830` VX-826 pins · `479986cde` VX-826 fix (A-809-10) · `728eda7a7` the two-store catalog + the two `list_notes` leaks fixed · `7cefb61e4` red-on-old of those + canon draft · this commit.

**Pins and their revert verification (every bug-class row red-on-old):**
- VX-825 retirements — `MCPReachPureAnswersServerTests` (8 tests incl. 3 `tag_unused` cases): RED on `56a3a7334` (pins added before the build; logged byte differences — the count, "a book not shared with you", the hidden book's id), GREEN after.
- A-809-4 hidden-cause refusals — `MCPHiddenCauseServerTests` (5 tests, 6 cases): RED with the call sites set aside (every arm carried the hidden owner/claimant/frozen book's `F0000000-…` id), GREEN after.
- VX-826 — the exact repro (`MCPDuplicateDateTitleServerTests`, 3 forms): GREEN on today's tree, RED with VX-759's `keepingNamedDay` forced off ⇒ HOLLOW on today's tree (fixed by VX-759; not re-fixed). The journal class (`DuplicateDateTitleTests`, 4 cases): RED on `0e8e00830`, GREEN after the `DuplicateDay` edit; residual guards (typed-titled ×2, dated journal, saved version) green on both sides by design.
- The catalog's two `list_notes` leaks — RED with `MCPReadTools.swift` at `1805c2d50` (6 arms), GREEN restored.
- **The coordinator's socket-harness trap, applied retroactively:** every red/green leg above was a FILTERED run of its own suite(s), and every red was a CONTENT assertion printing the pre-fix bytes (hidden ids, counts, refusal words) — never an initialize/connect timeout, the starvation signature a concurrent run produces — so the verdicts stand; noted here rather than re-run. Any further red-on-old or merge-gating socket-suite run goes to the orchestrator first (rule 2).
- Features (no red-on-old owed): the brain (`TagUsageQueriesTests`, 8) and `tag_unused_in_reach` (wire pins above).

**The forks, as ruled and built:** F-1 → A-809-8 (her sentence verbatim; `beyond_reach` always present on remove_tag / duplicate_note / move_note_to_wing landed answers) · F-2 → A-809-4 (the reachable verdict; P-809-2's two sentences; S-2 folded; S-1/#218 her words) · F-3 → A-809-9 (`tag_unused_in_reach` + `Queries.tagSubtreeIsWorn`, block tags included — the wire's passage search sees them; no wire tag listing exists) · F-4 → A-809-10 (`DuplicateDay` drops the journal guard; P-809-7). **Open for the orchestrator:** F-5 (lean (a): a wire-triggered intake seat that would fence the note bells instead) · F-6 (lean (a): the vocabulary stays reachable state).

**Test counts (the END, headless, this tree):** whole package `swift test`: core "━ Test run with 3663 tests in 494 suites passed after 299.209 seconds with 5 known issues." (the 5 known issues are the protection pair-invariant `withKnownIssue` pins, not this batch's) · "✔ Test run with 32 tests in 4 suites passed after 36.931 seconds." · MCP "✘ Test run with 566 tests in 104 suites failed after 58.107 seconds with 3 issues." — all three the socket-timing family (`MCPStopRoadsServerTests.aQuitSaysNothing…` "got no answer to its initialize"; `MCPHarnessTimeLimitTests` 45 s past its 15 s bound; `MCPReaderAfterCloseTests` premise failures) — re-run ALONE: "✔ Test run with 11 tests in 3 suites passed after 11.205 seconds." Skipped lines read: only the gated measurement suites (13o, VX-497, VX-653/654 probes) skip, by their gates. The batch's own suites all ran in the whole-package run.

**Files touched (25; no `App/`, no `App/Variorum/Shared/`, no `Sync/`, no `Protection/`, no migration, no dependency):** Sources — `VariorumCore/Domain/DuplicateDay.swift` (guard + one doc bullet — the VX-845 seam), `VariorumCore/Queries/TagUsageQueries.swift` (new — the shared brain), `VariorumMCP/MCPBeyondReach.swift` (new), `VariorumMCP/MCPHiddenCause.swift` (new), `MCPReadTools.swift` (list_notes), `MCPToolCatalog.swift` (three descriptions), `MCPWriteTools.swift` (add_note_to_book), `+DuplicateNote`, `+RemoveTag`, `+WingMove`. Tests — new: `MCPReachPureAnswersServerTests`, `MCPHiddenCauseServerTests`, `MCPDuplicateDateTitleServerTests`, `MCPTwoStoreCatalogServerTests`, `MCPTwoStoreCatalogArms`, `TagUsageQueriesTests`, `DuplicateDateTitleTests`; justified edits: `MCPDuplicateBriefServerTests`, `MCPDuplicateDatingServerTests`, `MCPDuplicateNoteFilingServerTests`, `MCPRemoveTagStrandedServerTests`, `MCPWingMoveServerTests`, `DuplicateKeepsItsDayTests`; harness: `MCPServerTests.swift` (`ServerHarness(seed:)` + `HarnessSeededGenerator`, default unchanged).

**Surprises:** (1) the catalog found two leaks nobody had listed — `list_notes`' `book_ids` carried unreadable books' ids on every row, and a paged `list_notes` carried a HIDDEN note's id inside its base64 `next_cursor` (and a gathering cursor counted hidden notes); (2) `move_note_to_wing`'s `left_books` crossed an unreadable book's raw id, not merely a count; (3) the agent's VX-826 repro is VX-759's class (hollow on today's tree); (4) F-5 — the vanishing-note class is real and topic-shaped; (5) a residual noted, not observed: a book's member position key is minted between neighbors, hidden ones included, so a `book`-shape `next_cursor` (opaque base64 of the last kept row's position) is only as reach-pure as positions are — the catalog's control and law passed with Private members both first and last in order, so no instance was found.

### FORK F-1 — the fixed scope words (P-809-1) — PROPOSED, orchestrator to rule

**The sentence (lean):** `Books beyond your reach, if any, are not listed.` — her sketch, made a sentence.
**One alternative:** `Only books you can read are listed here.` (positive phrasing; drops "if any", which some readers hear as a hint).

**Placement (lean) — ONE key, one value, everywhere, ALWAYS present on these tools (never conditional — a conditional key is itself an oracle):** `"beyond_reach": "<the sentence>"`.
- `remove_tag` (landed): `still_in_books` ALWAYS present — the READABLE living books still holding the note by the tag (`{book_id, name}`, `[]` when none) — plus `beyond_reach`. `still_in_books_hidden_count` RETIRES. Consequence: the VX-764 "nothing stranded answers byte-unchanged (no key)" guard is SUPERSEDED — under the law the bare answer cannot stay bare only when nothing hidden is stranded, so every landed `remove_tag` carries the two keys. *(Option (ii), rejected as lean: keys present only when the readable list is non-empty, the bare pre-VX-764 bytes otherwise — pure too, and keeps the old guard, but the bare answer then says nothing exactly when a hidden board kept the note; her "honesty by humility" reads as the always-present words.)*
- `duplicate_note` (landed, both forms incl. `brief`): `landed`'s prose is computed from READABLE books only ("a book not shared with you" / "N books not shared with you" RETIRE) — and `beyond_reach` rides beside it. Residual, said plainly: when only an unreadable book took the copy in, `landed` reads the Pool words ("the Pool of Home"), which is the client's-eye truth; `beyond_reach` is what keeps that from being a claim of totality.
- `move_note_to_wing` (landed): `left_books` lists ONLY readable books, each `{book_id, name}` (today an unreadable book is listed by its **id** with no name — the id itself crosses; that is worse than a count and retires with it) — plus `beyond_reach`. Her receipt keeps the full count (hers, not the wire's).
- Batches 2–3 reuse the same key and sentence (`move_book_to_wing`, `replace_tag`).

Building the plumbing now around a single constant (`MCPWriteTools.beyondReachKey` / `.beyondReachWords`) so the ruling changes one line.

### FORK F-2 — the ownership refusals (P-809-2) — PROPOSED, NOT BUILT

**Every wire act that can hear `noteOwnedElsewhere` / `noteMemberedElsewhere`** (traced from the throw site `Operations+Ownership.swift:35 consultOwnership`, called by `addPostToReading` and `seatArrival`):
1. **`add_note_to_book`** — `addNoteToBookForClient` → `addPostToReading` (`Operations+MCPWrites.swift:998`) on an EXISTING note: the ONE live wire road. Owned target + the note membered in any other book → `noteMemberedElsewhere`; plain target + the note membered in an owned book → `noteOwnedElsewhere` (`OwnershipDecision.verdict`). The wire speaks her table's words (`OpsRefusalTable`): "That note already lives in another book, and this book owns its notes — …" / "That note belongs to a book that owns its notes — …" — no book named, but the KIND (owned vs membered) of the claimant is said.
2. NOT reachable (verified in code): `create_note` / `import_document` / `duplicate_note` with `book_id` (each adds a FRESH note, membered nowhere → the consult always says add, `Operations+MCPWrites.swift:662`, `Operations+Versions.swift:321`); every INTAKE road the wire triggers — `apply_tag`, `set_starred`, `set_book_rule`, `create_book`/`create_gathering` with a rule — decides ownership inside `IntakeDecision` and BELLS, never throws; `seatArrival` (her judgment op) has no wire tool; Copy in / Move in / Own have no wire tool (Own is hers alone). *(The kickoff comment's "may be unreachable by construction" is half right: intake never reaches it; the hand-add does.)*

**Siblings of the same class (a refusal forced by a hidden fact, where the none-exist store succeeds) — found in the survey, enumerated so the ruling can speak for them too:**
- **S-1 capacity** — `add_note_to_book`, `create_note`/`import_document`/`duplicate_note` with `book_id`: `readingAtCapacity` counts hidden members (Private notes in a granted book). Her QUESTIONS #218 ruling ACCEPTED this inference in 2026-10 ("it'll still see that it's hitting the limit, but i think that might be fine") — R-825 post-dates it and says "nothing on the wire may vary"; the orchestrator rules whether #218 stands as a second named exception or folds in.
- **S-2 the frozen-book move** — `move_note_to_wing` on a note held by a FINISHED or SEALED book the client cannot read: her op refuses (`lockedReading`/`readingSealed`); the wire names the book only where readable (`frozenWords`), else the op's own words ("This book is finished/sealed…") — the move succeeds in the none-exist store.

**Shapes (leak analysis per shape; "the forced bit" = a refusal where the none-exist store succeeds — unavoidable, since ownership/capacity/finish are real):**
- **(a) LEAN — the reach-pure verdict + ONE fixed sentence.** The refusal's words are a pure function of the REACHABLE verdict and the act's outcome: decide ownership over the claimants the client can READ; where that reachable verdict refuses, her words stand (they describe reachable state — the claimant is readable); where it would ADD but the true verdict refuses (every claimant unreadable — or, S-1/S-2, the cause is hidden), the answer is ONE fixed sentence naming no book, no count, no kind, e.g. *"That note can't be added to this book — something beyond your reach holds it. The author can add it in Variorum."* (per act: "…can't be moved…" for S-2). Leak: exactly the forced bit, said honestly; nothing about WHICH, HOW MANY or WHAT KIND (owned vs membered collapse into one sentence). Recorded as the law's ONE explicit exception with its why (ownership is real; a client can never be told success it did not get).
- **(b) her words unchanged** (today's behavior). Leak: the forced bit PLUS the claimant's kind ("owns its notes" vs "lives in another book") — two distinguishable answers where (a) has one; and through S-1 a count inference (the #218 class). Rejected as lean: more than the minimum.
- **(c) an opaque refusal** — *"You can't add this note to this book — ask the author to add it in Variorum."* — no cause at all. Leak: the forced bit only (same as (a)), but the agent can't reason about it, and the words are indistinguishable from a rung problem it could otherwise fix. Rejected as lean: (a) is equally minimal and honest.
- Off the table (the record's): "pretend the note is fine" (answer not-shared — a lie about a reachable note) and "just succeed" (breaks ownership).

The two-store catalog pin asserts the P-809-2 arms (and S-1/S-2 if ruled in) as the ONLY differing rows, each differing in exactly the ruled way.

### FORK F-3 — scope question (VX-825's titular ask) — ASKED

VX-825's TITLE and its first ask — "remove_tag's answer says when a tag looks unused within the client's reach; deletion stays hers" (the ticket's body: "remove_tag's answer (and the tag listing's rows) speak REACH-SCOPED usage — 'no note this client can see wears it'") — is not one of BATCH 1's four parts, but BATCH 5's VX-840 text refers to "batch 1's arm reads the same predicate under a reach filter". **Question to the orchestrator: is the reach-scoped "unused" fact in this batch?** If yes, the lean shape: a landed `remove_tag` adds `tag_unused_in_reach: true|false` — whether any note this client can READ still wears the tag (post_tag only; the probe stops at the first readable wearer, ∝ the tag's wearers in the worst case), computed through `decide(..., rung: .read)`, never a library-wide count; the description says the fact is reach-scoped and that deleting a tag is the author's (Settings ▸ Tags). Building nothing here until ruled.

### VX-826 — the trace (B1-9)

**The derivation (read in code):** a note's displayed name is `DisplayTitle.note(title, entryDate, createdAt)` — the title, else `entry_date`, else the LOCAL day of `created_at` (`DisplayTitle.swift`; every wire title — `read_note`, `list_notes`, `mcpScopeTitle` — and every app title read the same rule). A copy is born today (`copyPost` stamps `createdAt: now`), so a copy whose title and `entry_date` are both absent reads TODAY. `copyPost(keepingNamedDay: true)` (the shared body, `Operations+Versions.swift:797`) gives the copy `DuplicateDay.entryDate(...)`: an undated, untitled, NON-JOURNAL source's copy takes the source's creation day — so that class reads the source's name. Every other class keeps `title`/`entry_date` verbatim.

**So exactly one title class still derives "today" on the current tree:** a JOURNAL-PROFILE source (`profile = 'journal'` — every ⌘J entry) with no title and no `entry_date` (or `entry_date = ''`) — VX-759 kept it undated deliberately (the notebook rule keys on `profile='journal' AND entry_date`; `DuplicateDay`'s doc). Reachable by HER doors: a ⌘J entry whose date she cleared (Editor's date door, `setEntryDate(nil)`), then Duplicate with/without Tags or Copy to Wing → the copy reads today. **Not reachable on the wire:** `profile='journal'` is a fence leg (`MCPGrantQueries.swift:514`), so `duplicate_note` / `copy_note_to_wing` refuse a journal-profile source in the fence's one sentence.

**The exact repro (the agent's "2 of 7")** — an automatic date title (untitled, undated, non-journal — the only class the wire can duplicate) — reads the SOURCE's day on the current tree (VX-759's class, fixed by `3f2f650d4`). The ticket was filed 2026-11-05T02:56Z (11-04 19:56 MST); VX-771 merged 11-04 07:27 with the /Applications refresh HELD and 1.1 cut at 21:50 — so the agent's 2-of-7 is consistent with a build WITHOUT VX-759 (its "came over correctly dated" matches a dated source's copy, verbatim since long before VX-759). **PENDING the pin:** the exact-repro pin green on the current tree and red with VX-759's `keepingNamedDay` reverted → the reported repro is HOLLOW on today's tree (record, don't re-fix), and the journal class is the real remainder.

**FORK F-4 (proposed P-809-7) — the journal class's fix (R-826: "a date-titled note's copy reads the SOURCE's displayed title, never today's"):**
- **(a) LEAN — extend `DuplicateDay` to the journal class:** an undated, untitled JOURNAL-profile source's copy takes the source's creation day as `entry_date` too. Keeps `DisplayTitle` a pure display rule (no title write) and keeps the one mechanism VX-759 ratified. Cost, said: such a copy is a journal-profile note dated D, so `canonicalJournalEntry(D)` may pick it when D has no earlier entry (the earliest `created_at` wins, so a day with ANY older entry is unaffected) — the same claim a duplicate of a DATED ⌘J entry already makes today (its `entry_date` is copied verbatim), so the notebook exposure is the shipped one, not a new kind.
- **(b) materialize the displayed title** (the agent's "copy the displayed title as-is"): the copy's `title` = the source's displayed date string, journal class only. Satisfies R-826 with zero notebook effect, but WRITES a derived title — against `DisplayTitle`'s "never a write … nothing is copied (the no-denormalization rule)".
- **(c) keep as built** (VX-759's journal exclusion) and record R-826's letter unmet for the class — rejected: R-826 says "never today's".
Building (a) PROVISIONAL unless ruled otherwise; red-on-old pin on the journal class through her Duplicate doors AND Copy to Wing (the shared body); byte-verbatim pins for the typed-titled and dated classes.
