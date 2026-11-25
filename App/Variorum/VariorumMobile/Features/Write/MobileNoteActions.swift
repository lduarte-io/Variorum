//
//  MobileNoteActions.swift
//  VariorumMobile
//
//  **THE NOTE'S ⋯ — the masthead's note-scale acts** (round 2, batch 4).
//  Two rows arrive with it, and they are the two things the phone most
//  visibly lacked:
//
//  · **M20's persistent undo/redo door** (her R10) — the companion to the
//    receipt's Undo, for acts whose receipt has already passed. It carries
//    the stack's live `topLabel` / `topRedoLabel`, so the rows say what
//    they will do ("Undo Divide", "Redo Delete Blocks") instead of naming
//    a direction and hoping.
//  · **PR1's Delete Note…** — the phone had NO note-delete door anywhere
//    (the parity inventory's headline). Move to Trash, confirmed, with the
//    destination and the clock named.
//
//  **BATCH 6c ADDS THE NOTE'S TWO TIME CONTROLS** — `Save a Version` and
//  `Versions…` — and the pairing IS a teaching surface, not a pair of rows
//  (the archive/trash design record's finding 2). The Mac teaches the two
//  sizes of moment with two chords: ⌘S saves THIS TAKE's moment, ⌘⇧S saves
//  THIS NOTE's. The phone has no chord culture (PL-11's own words), so the
//  teaching needs another home — and it already had one, because the phone
//  keeps block acts in the **block ⋯** and note acts here. **As it stood
//  at 6c, kept because it was TRUE WHEN WRITTEN** (`MobileBlockMenu`'s own
//  convention for a superseded note):
//
//      block ⋯  →  Commit Take    +  Block History…
//      note  ⋯  →  Save a Version +  Versions…
//
//  **THE BLOCK ROW OF THAT DIAGRAM IS HISTORY, NOT CURRENT** (round 2,
//  batch 9 — her ⋯ letter: *"take history should move into the three ...
//  menu on each take rather than the main three dot menu"*). `Block
//  History…` left the block ⋯ and now lives on every live take card's
//  own ⋯ in the takes browser (`MobileTakesBrowserController.historyTitle`),
//  so the block grain's pair is broken on purpose — `MobileBlockMenu`'s
//  header carries the whole reasoning. What SURVIVES is exactly the row
//  below it: the NOTE ⋯ still holds its own *write a moment / see the
//  moments* pair, which is now the only place the phone teaches it, and
//  which is why this file's own shape did not change.
//
//  Two grains, and since batch 9 only ONE of them still holds its own
//  *write a moment / see the moments* pair here. **PROVISIONAL — the
//  design record's Q5:** it grows a
//  three-row sheet to five, and the alternative (a sixth masthead chip) was
//  refused because that row already wraps five and its crowding is flagged
//  for her.
//
//  **Why a SHEET and not a `Menu`** (the inventory recommended a `Menu`;
//  this is the recorded deviation, and it is the round's own trap-2 rule
//  paying rent): a SwiftUI `Menu`'s rows present into a separate context-
//  menu hierarchy that a pin cannot reach — measured, not assumed (the
//  probe: activating the Menu presents a `_UIContextMenuActionsOnlyView-
//  Controller` whose accessibility tree comes back EMPTY). Under §15's
//  trap (b) — *every door in this batch gets a pin that mounts the real
//  surface and drives the real control* — a Menu row is a door no pin can
//  drive, which is how the Mac's dead purge doors shipped. A sheet's rows
//  are ordinary Buttons: findable, activatable, and pinnable. It is also
//  the phone's own established grammar for summoned machinery (membership,
//  tags, references, blocks, lenses all present this way from this exact
//  masthead), and it leaves room for the tray and lineage doors the ledger
//  still owes this surface.
//
//  **The destructive dialogs here NEVER use the Mac's dead pattern** (§15's
//  trap (a)): both are `.alert(..., isPresented:)` over a real `@State` or
//  a `@Bindable` model property — the phone's shipped immune road.
//

import SwiftUI
import VariorumCore

struct MobileNoteActionsSheet: View {
    /// `@Bindable` so `$door.pendingWarning` is a REAL observation
    /// dependency — never a `Binding(get:set:)` computed over a property
    /// `body` does not read (the Mac's `RecoveryView` dead-door defect).
    @Bindable var door: MobileUndoDoor
    let model: MobileEditorViewModel
    let tokens: VoiceTokens
    /// The note went — the screen must navigate away from a tombstone.
    let onDeleted: () -> Void
    /// **Versions… (batch 6c)** — dismiss this sheet and push the note's
    /// Versions screen. nil in harness/preview use, where the row is still
    /// rendered and pinned: it is the DOOR that is optional, never the row,
    /// so a pin can prove the row exists and fires.
    var onOpenVersions: (() -> Void)?
    @State private var deletePresented = false
    /// The entry date's alert (parity C2, her sitting item 4) — its door moved
    /// here from the note's top with R-260-13.
    @State private var datePresented = false
    @State private var dateField = ""
    @Environment(\.dismiss) private var dismiss
    /// **Settings, from a note** (VM-53 — the ticket: Settings "reachable from
    /// every root and from a note"). The shell's door, from the environment
    /// (`MobileSettingsGear.swift`); nil outside a shell, and then no row (P-2).
    @Environment(\.mobileSettingsDoor) private var settingsDoor
    /// Set by the Settings row: the shell's sheet is asked for only once THIS
    /// sheet has gone (`onDisappear`), so two presentations never overlap.
    @State private var settingsAfterClosing = false

    static let sheetTitle = "Note"
    /// The masthead door's accessibility name (the pin's handle, and what
    /// VoiceOver says for a bare ⋯).
    static let doorLabel = "Note Actions"

    var body: some View {
        // R-260-13 (the VM-260 run, batch 4b): the sheet SCROLLS — its head
        // grew by the two doors, and at the medium detent its last rows (Delete
        // Note… above all) must stay reachable without a drag to large.
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                PhoneSheetHeader(tokens.chromeLabel(Self.sheetTitle), tokens: tokens) { dismiss() }
                // The seal and the date head the sheet (R-260-13): two easy
                // doors above its rows, where she asked for them.
                headDoors
                // The note's two TIME controls first — the grain pairing the
                // phone teaches here instead of with chords (finding 2).
                saveVersionRow
                versionsRow
                Divider().overlay(tokens.line)
                undoRow
                redoRow
                settingsRow
                Divider().overlay(tokens.line)
                deleteRow
            }
            .padding(20)
        }
        .background(tokens.room.ignoresSafeArea())
        // VM-53: the Settings row's ask, once this sheet is gone (a swipe-down
        // or Done never asks).
        .onDisappear {
            guard settingsAfterClosing else { return }
            settingsAfterClosing = false
            let door = settingsDoor
            Task { @MainActor in door?.open() }
        }
        // A12's destructive-undo warning — raised only when the undo would
        // set aside text edited since the operation (the insurance class).
        // Bound to THIS surface, so the masthead's twin host stays quiet
        // while the sheet is up.
        .alert(
            door.pendingWarning.map(
                { StructuralUndoCopy.discardingUndoQuestion($0.warning) }) ?? "",
            isPresented: $door.warningAtSheet
        ) {
            Button(tokens.chromeLabel("Undo"), role: .destructive) {
                let door = door
                Task { await door.confirmPendingUndo() }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) { door.cancelPendingUndo() }
        } message: {
            Text(door.pendingWarning.map(
                { MobileUndoDoor.discardingUndoDetail($0.warning) }) ?? "")
        }
        .alert(
            MobileEditorViewModel.deleteNoteConfirmTitle,
            isPresented: $deletePresented
        ) {
            Button(tokens.chromeLabel("Delete"), role: .destructive) {
                let model = model
                Task {
                    if await model.deleteNote() {
                        dismiss()
                        onDeleted()
                    }
                }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {}
        } message: {
            Text(MobileEditorViewModel.deleteNoteConfirmDetail)
        }
        // The entry date (parity C2 — set AND clear; the alert-confirmed door is
        // the rename door's own grammar). R-260-13 moved it here with its door.
        .alert(MobileNoteTopDoors.dateName, isPresented: $datePresented) {
            TextField("2026-08-09", text: $dateField)
                .keyboardType(.numbersAndPunctuation)
            Button("Set") {
                let day = dateField
                let model = model
                Task { await model.setEntryDate(day) }
            }
            Button("Clear Date") {
                let model = model
                Task { await model.setEntryDate(nil) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A date makes this a day's entry — journals sort by it. Plain days only (2026-08-09); Clear leaves the note undated.")
        }
    }

    /// **The sheet's head — the seal and the date** (R-260-13, her words:
    /// "sealing the note can also go in the note's menu (maybe it can stay an
    /// easy to click icon at the top of the note menu instead of another row)
    /// … date could go in the note menu, again it could be an easy to click
    /// icon at the top"). Two of the phone's calm buttons side by side, each a
    /// glyph over its word, each answering across half the sheet and well over
    /// 44 tall:
    /// · **the seal** — the note seal's door, moved from the top (parity A1
    ///   item 4 — "you should be able to unlock a note and lock it on
    ///   mobile"): one reversible tap either way (the seal is a guard, never a
    ///   snapshot — I6); the glyph and the accent say it is sealed, the word is
    ///   the act ("Lock" / "Unlock", inside the spoken "Lock Note" / "Unlock
    ///   Note"). The sheet stays up: a guard, not a departure.
    /// · **the date** — the "no date" chip's act: the day when set, in ink,
    ///   else "no date" in the muted; it opens the Entry Date alert.
    private var headDoors: some View {
        let day = MobileWriteScreen.dateChipDay(model)
        let sealed = model.isSealed
        return HStack(spacing: PhoneMetrics.Space.s8) {
            Button {
                let model = model
                Task {
                    if model.isSealed {
                        await model.unlockNote()
                    } else {
                        await model.lockNote()
                    }
                }
            } label: {
                headLabel(
                    symbol: sealed ? "lock.fill" : "lock.open",
                    word: sealed ? MobileNoteTopDoors.unlockWord : MobileNoteTopDoors.lockWord)
            }
            .buttonStyle(PhoneCalmButtonStyle(tokens: tokens, tone: sealed ? .accent : .ink, fullWidth: true))
            .accessibilityLabel(sealed ? MobileWriteScreen.unlockDoorTitle : MobileWriteScreen.lockDoorTitle)
            Button {
                dateField = MobileWriteScreen.dateChipDay(model) ?? ""
                datePresented = true
            } label: {
                headLabel(
                    symbol: MobileNoteTopDoors.calendarSymbol,
                    word: day ?? MobileNoteTopDoors.noDateWord)
            }
            .buttonStyle(PhoneCalmButtonStyle(tokens: tokens, tone: day != nil ? .ink : .muted, fullWidth: true))
            .accessibilityLabel(MobileNoteTopDoors.dateName)
            .accessibilityValue(day ?? MobileNoteTopDoors.noDateWord)
        }
    }

    /// A head door's face: its glyph (the icon button's 17) over its word.
    private func headLabel(symbol: String, word: String) -> some View {
        VStack(spacing: PhoneMetrics.Space.s4) {
            Image(systemName: symbol)
                .modifier(PhoneGlyphModifier(size: PhoneControlMetrics.iconGlyph))
                .accessibilityHidden(true)
            Text(tokens.chromeLabel(word))
                .lineLimit(1)
        }
    }

    /// **A refusal raised HERE is spoken where she can see it** (§49's MINOR:
    /// *a refusal spoken behind the presenting sheet*). On a refusal this
    /// sheet deliberately STAYS UP (a refused delete must not look like it
    /// went). VM-61: every act here reports through
    /// `MobileEditorViewModel.report`, which speaks on the shell's ONE line —
    /// and that line draws ABOVE this sheet (its own window), so the sentence
    /// is in view without a slot of the sheet's own.

    /// **Save a Version** — ⌘⇧S's phone twin, and the whole note's moment.
    /// The sentence is the shared one (`VersionsPath`): the Mac and the
    /// phone must not describe one machinery two ways.
    ///
    /// The sheet STAYS UP: this is a save, not a departure. A refusal speaks
    /// on the shell's one line above the sheet (VM-61); a landed save is an
    /// ordinary act and says nothing (her ruling).
    private var saveVersionRow: some View {
        actRow(
            title: VersionsPath.saveVerb,
            detail: Self.saveRowDetail,
            tint: tokens.accent
        ) {
            let model = model
            Task { await model.saveVersion() }
        }
    }

    /// **Versions…** — the moments of this note. Dismiss the sheet, then ask
    /// the shell to push.
    ///
    /// **The order is deliberate; the "proven road" claim this comment used
    /// to make was not** (the cold review's m4). It cited the shell's
    /// settings-sheet grammar — which is DEBUG-only, unpinned, and a
    /// different shape: there the shell flips its own `settingsPresented`
    /// flag and appends to the path in ONE scope, while here an
    /// environment `dismiss()` inside the sheet is followed by a callback up
    /// the tree. Nothing was measured, and no failure was ever traced. What
    /// the fix wave did instead of re-asserting it: DRIVE the composed road
    /// on a mounted `MobileShellView`
    /// (`MobileVersionsTests.theVersionsRowOpensTheRoomThroughTheWholeShell`),
    /// so the claim is a pin rather than a comment.
    private var versionsRow: some View {
        actRow(
            title: VersionsPath.menuLabel,
            detail: Self.versionsRowDetail,
            tint: tokens.accent
        ) {
            dismiss()
            onOpenVersions?()
        }
    }

    // MARK: - The two rows' own detail lines (phone-voiced, and listed)

    /// **These two lines are the phone's OWN, and that is a recorded gap
    /// rather than a licence** (the cold review's m2). `VersionsCopy` holds
    /// every SENTENCE about the machinery; what it has no home for is a
    /// menu row's one-line detail, which is a face fact — an iOS sheet row
    /// has a subtitle and a Mac menu item does not.
    ///
    /// The first draft's save-row line read *"saves this whole note as it is
    /// right now"* — one word off a clause inside `VersionsPath.empty`, i.e.
    /// the same sentence living twice, which is exactly what that shared
    /// file's header forbids. It is re-voiced here to say what the row
    /// LEAVES BEHIND rather than to restate the act, and the pin
    /// (`theVersionsVocabularyIsSharedAndEveryPhoneVoicedLineIsListed`)
    /// enumerates all four phone-voiced Versions strings and holds them
    /// clear of the shared sentences.
    ///
    /// **`VersionsPath.saveDetail` is the durable answer** and it is on the
    /// next Shared-touching batch's list (`Shared/` is fenced this round).
    static let saveRowDetail = "keeps a moment of the note, to come back to"

    /// Composed from the shared VERBS rather than invented: this row's
    /// detail is a list of what is behind the door, and those three words
    /// are `VersionsPath`'s own.
    static var versionsRowDetail: String {
        "\(VersionsPath.openVerb.lowercased()), "
            + "\(VersionsPath.restoreVerb.lowercased()) or "
            + "\(VersionsPath.promoteVerb.lowercased()) a saved moment"
    }

    /// **Settings…** (VM-53): this sheet closes, then the shell's Settings
    /// sheet opens over the note — Done there returns her to the note. Its word
    /// is Settings' door word on screen today; it has no detail line (none is
    /// drafted for it).
    @ViewBuilder
    private var settingsRow: some View {
        if settingsDoor != nil {
            // Its own hairline only when an undo or redo row sits above it —
            // otherwise the group's divider after Versions… already separates
            // them, and two would draw 14 pt apart (VM-47, the walk's W-B4).
            if door.undoLabel != nil || door.redoLabel != nil {
                Divider().overlay(tokens.line)
            }
            actRow(title: Self.settingsTitle, detail: nil, tint: tokens.accent) {
                settingsAfterClosing = true
                dismiss()
            }
        }
    }

    static let settingsTitle = "Settings"

    /// The stack's undo end. Rendered only when there IS one — P-2: a door
    /// that can never act in its context isn't rendered, and "Undo" with an
    /// empty stack is exactly that.
    @ViewBuilder
    private var undoRow: some View {
        if let label = door.undoLabel {
            actRow(
                title: StructuralUndoCopy.undoDoorTitle(label),
                detail: "puts the last structural change back",
                tint: tokens.accent
            ) {
                let door = door
                Task { await door.beginUndo(from: .sheet) }
            }
        }
    }

    @ViewBuilder
    private var redoRow: some View {
        if let label = door.redoLabel {
            actRow(
                title: StructuralUndoCopy.redoDoorTitle(label),
                detail: "re-applies what you just undid",
                tint: tokens.accent
            ) {
                let door = door
                Task { await door.redo() }
            }
        }
    }

    /// The removing act wears the voice's ALARM, last (sheet §D: the alarm
    /// "replaces the literal red on Delete note…"; §E's menu row — VM-47, the
    /// walk's W-B3: the system red read 3.43:1 on the room).
    private var deleteRow: some View {
        actRow(
            title: MobileEditorViewModel.deleteNoteTitle,
            detail: RecoveryCopy.moveToTrashDetail(.note),
            tint: tokens.alarm, role: .destructive
        ) {
            deletePresented = true
        }
    }

    /// One row shape for every act — a real `Button` (never a `Menu` row),
    /// labelled for VoiceOver and for the pins that drive it.
    /// The tint is a PARAMETER rather than a ternary inside the modifier
    /// (clearer, and it was written that way while chasing the note below),
    /// and the destructive row ALSO carries `role: .destructive` — the
    /// idiomatic iOS marking, which is what a `UIAlertController` uses for
    /// the same idea.
    ///
    /// **RECORDED OBSERVATION for the visual pass, measured not guessed:**
    /// in a `layer.render`-based capture of this sheet, SYSTEM semantic
    /// colours (`.red`, `.green`, `.orange`) render as the default label
    /// colour while a custom `Color` (`tokens.accent`) renders correctly —
    /// verified by changing the colour four ways, by a title probe proving
    /// the build was fresh, and by the fact that the very same `.red`
    /// renders red in `MobileTrashView`'s root-level rows and in the UIKit
    /// confirm's own destructive action in the same capture. Most likely a
    /// capture artifact of rendering a presentation container's layer, not
    /// a product defect — but it is a colour a DELETION door depends on
    /// (principle M-E), so it is flagged for a device look rather than
    /// assumed good.
    private func actRow(
        title: String, detail: String?, tint: Color,
        role: ButtonRole? = nil, act: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: act) {
            VStack(alignment: .leading, spacing: 2) {
                Text(tokens.chromeLabel(title))
                    .phoneType(.control, tokens)
                    .foregroundStyle(tint)
                if let detail {
                    Text(tokens.chromeLabel(detail))
                        .phoneType(.meta, tokens)
                        .foregroundStyle(tokens.phone.muted)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        // VM-50: the menu row — a title and a detail line, 64 at least (VM-53:
        // a row with no detail line, the one-line menu row's 44).
        .buttonStyle(PhoneMenuRowStyle(minHeight: detail == nil
            ? PhoneControlMetrics.menuRowPlain : PhoneControlMetrics.menuRowWithDetail))
        .accessibilityLabel(title)
    }
}
