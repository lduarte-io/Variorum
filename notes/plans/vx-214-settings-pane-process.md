# The settings-pane wording pass — process note (for her next agent)

*Written 2026-10-13 by the VX-214 orchestrator at her instruction, as she went to bed: "I want you to write a note for what our process of going through the settings pane is like, mint a ticket about it for me, and I'll pick that work up later with a different agent." This note is that record — self-contained for a fresh session. The worked example is General, done 2026-10-13 in the VX-214 run (`notes/plans/fixes/vx-214-settings-launch-polish.md`, the sitting record), and **her word: "our changes to the general pane can stand."***

## The loop (one pane at a time)

1. **The agent presents ONE pane**: its sections in render order, every control's title, every rendered caption VERBATIM (abridge only the very longest, saying so), plus anything the agent noticed — caps-rule violations, doctrine mismatches, overlong captions, controls that look mis-homed. Pull the real strings from the code, never from memory: titles render from `SettingsShape.swift`'s `SettingsCatalog` (single-sourced — a control never retypes its title), captions live beside the panes in `App/Variorum/Variorum/Features/Settings/` (per-feature `*Copy.swift` files and inline `Text`s in `AppSettingsView.swift`).
2. **She rules per control** — cut, reword, reorder, or broader direction. Her wording can be a sketch ("something more direct like …"); the agent drafts the final sentence and shows it back.
3. **Rulings land VERBATIM in the run record's sitting section the same turn** (repo-first, before building). Build notes beside them record every judgment call the agent made inside a ruling.
4. **The agent builds immediately** in-tree and reports back point-by-point, flagging its judgment calls (e.g. General: dropping the "Voice" section header when "Theme" became the control's name, so the word reads once).
5. **Tests ride the change**: `SettingsShapeTests` (pane shape — it PINS which panes have subtitles), `ConfirmationsSettingTests`, `CommitVocabularyTests` (the commit-vocabulary fence sweeps every catalog string). A caption change that breaks a pin updates the pin in the same commit — that is a doc-change, not a hallucination-guard event. `xcodebuild build` is stage-free; `xcodebuild test` needs a held `Tools/stage` claim (coordinate if other sessions are live).

## Standing rules that bind every pane

- **No shouty caps in rendered copy** (her standing rule — General's old "REFUSES" was exactly this).
- **The commit vocabulary says "commit"** (R-13s-31/32); sentences that *define* commit may say "saved moment".
- Message kinds are refusal · offer · receipt, decided at the door (AppSpec §12) — copy must not promise "Off" silences refusals; her ruled sentence for this is in `ReceiptStyleCopy.help`.
- **Copy truth**: a caption must not claim more than the mechanism (e.g. "committing" is not a *structural* act in the app's vocabulary — the orchestrator dropped that word from her Confirmations draft for exactly this).
- Renames keep the OLD name as a search keyword (`SettingsCatalog` keywords — the "promote" precedent). Search-registry blurbs deliberately KEEP detail the pane no longer shows; search results need context.
- P-8: every `fixedSize` chrome text carries a `lineLimit`; no literal colour outside the token layer.
- **Protection and Data Safety wording is custody-meaning content** — a pass that touches it earns a Fable cold review, and vx-201's register rules bind: no caps for emphasis, everyday surfaces name no key.
- The MCP pane's SettingsShape rows and `Features/MCP` were VX-184's surface in the 2026-10-13 runs; by the time this pass runs that run should be merged — rebase/read the landed shape first.

## State at this note's writing

- **General: DONE, STANDS** (her word). No subtitle (the one pane without; pinned), "Design voice"→"Theme" bare, Appearance bare, palette bare (the conditional custom-hex state/refusal notes stay — she ratified), Confirmations = her one paragraph, Open notes = "This Mac only.", Updates toggle bare.
- **Remaining panes for her pass:** Editor (presented to her 2026-10-13 — ten controls, four sections — but UNRULED; re-present at pickup) · Takes · Writing · Shortcuts · Tags · **MCP (her word: review for wording clarity — it was rebuilt by VX-184's U6 the same night)** · Protection · Data Safety · Diagnostics · Acknowledgments.
- **Parked observations for the pass:**
  - **British English**: the app's rendered copy is CONSISTENTLY British for colour/grey — ~11 "colour" sites (the palette family, Data Safety, the tutorial, Takes find) plus "greyed"; zero American "color" in rendered strings. Her open question ("why is it colour? are the rest also in british english?") — flipping to American would be one deliberate sweep; her call.
  - The Editor pane hosts a **"Books" section** (ownership badges + hide-owned) that is arguably mis-homed in a pane about the writing surface.
  - The gathering explainer under the note list was removed by VX-217 (the foot now matches a book's); the Services submenu was suppressed by VX-220 — neither needs pane work.
