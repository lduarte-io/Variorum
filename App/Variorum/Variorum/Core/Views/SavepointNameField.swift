//
//  SavepointNameField.swift
//  Variorum (Mac — `Core/Views`, the shared home)
//
//  13u3 UNIT D — **the name at the commit door** (master plan item 14, her
//  words: *"an optional name at the manual-commit door, enter-to-skip keeps
//  ⌘S instant"*; the rename half is her ruling R-13u3-1).
//
//  ── ONE FIELD, EVERY DOOR ────────────────────────────────────────────────
//  Five doors name a saved moment: ⌘S in Write, in Takes/Lenses, in Canvas
//  and in Compare, and the rename door beside a savepoint in Block History.
//  They are five places, one gesture, so they compose ONE view and ONE rule
//  (`SavepointName`, core) — the placement rule's own letter, since more
//  than one feature consumes it.
//
//  ── THE TWO KEYS ─────────────────────────────────────────────────────────
//  **⏎ files what is in the field — empty means unnamed** (so ⌘S ⏎ is two
//  keys and nothing is slower than it was), **⎋ cancels the whole gesture.**
//  Cancelling is not a third state to carry: the ask simply goes away
//  WITHOUT filing, which is what ⎋, a click outside and a closing window all
//  produce — one road, so a dismissal can never half-commit.
//
//  ── WHY A POPOVER AND NOT A SHEET ────────────────────────────────────────
//  A sheet takes the window for a one-line optional name, and her ruling's
//  whole point is that the fast road stays fast. The popover hangs at the
//  door that summoned it, takes the keyboard on appear (the ⌘K palette's own
//  idiom — `.task { focused = true }`), and returns it when it goes.
//
//  It claims NO global chord (⇧⌘V is `PlainPaste`'s, and everything else in
//  this file is a key the field owns only while it has the caret).
//

import SwiftUI
import VariorumCore

/// **A PENDING NAME** — which savepoint is being named, and what the field
/// opens with. A value, so a pin can hold the seeding and the identity
/// without presenting anything.
nonisolated struct SavepointNameAsk: Identifiable, Equatable {
    enum Kind: Equatable {
        /// ⌘S: the savepoint does not exist yet. ⏎ files it, named or not.
        case newSavepoint
        /// Block History's rename door: the savepoint exists (R-13u3-1).
        case rename
    }

    var kind: Kind
    /// The row the ask belongs to — the TAKE for a new savepoint, the
    /// SAVEPOINT for a rename. The owner acts on it; it lives here so the
    /// ask is self-describing and `popover(item:)` has an identity.
    var targetID: String
    /// What the field opens with: empty at the commit door (a savepoint is
    /// born unnamed unless she says otherwise), the current name at the
    /// rename door (renaming starts from what is there — and clearing it is
    /// how a name is removed).
    var seed: String = ""

    var id: String { "\(kind == .rename ? "rename" : "new"):\(targetID)" }

    static func naming(variantID: String) -> Self {
        SavepointNameAsk(kind: .newSavepoint, targetID: variantID)
    }

    static func renaming(_ commit: CommitPoint) -> Self {
        SavepointNameAsk(
            kind: .rename, targetID: commit.id,
            seed: SavepointRowFace.name(commit) ?? "")
    }
}

/// The field's words. Mac-local, deliberately: every one of them names a
/// KEY, and the shared face's own rule is that a sentence naming one
/// platform's chord does not live in the shared home.
nonisolated enum SavepointNameCopy {
    // **MEASURED ON THE WALK, NOT GUESSED** (13u3 UNIT D): the first
    // wording was *"name this moment (optional)"* and it TRUNCATED at the
    // field's own width in the Terminal voice's monospace — the door's
    // placeholder cut mid-word at the one width the field actually opens at.
    // The optionality is the hint's sentence to carry, not the prompt's.
    static let newPrompt = "name this moment"
    /// At the RENAME door the field opens on the current name, so the
    /// placeholder is only ever seen after she CLEARS it — and then it says
    /// exactly what ⏎ will leave behind.
    static let renamePrompt = "no name"

    static let newHint = "\u{23CE} saves it \u{00B7} \u{238B} cancels. An empty name is fine — "
        + "the moment is saved either way."
    // Also measured on the walk: the first rename hint ran to four lines at
    // the field's width and the third one truncated mid-word. What I5 says
    // — the moment's TEXT is never editable — is the door's `help` sentence
    // (`BlockHistoryCopy.nameHelp`), where there is room for it.
    static let renameHint = "\u{23CE} saves it \u{00B7} \u{238B} leaves it as it was. "
        + "Clearing the field removes the name."

    static func prompt(_ kind: SavepointNameAsk.Kind) -> String {
        kind == .rename ? renamePrompt : newPrompt
    }

    static func hint(_ kind: SavepointNameAsk.Kind) -> String {
        kind == .rename ? renameHint : newHint
    }

    /// The receipt when a savepoint is born NAMED — one sentence, all four
    /// commit doors, because the name is the news. An unnamed ⌘S keeps each
    /// door's shipped sentence (Write's is "Committed.").
    ///
    /// 13s-b U4 (her R-13s-31): the word is COMMIT. Where the sentence
    /// DEFINES what a commit is, "commit" would define itself — her own
    /// R-13s-32 note, *"commit twice would just read as weird"* — so the
    /// definition rides the app's own plain gloss, the SAVED MOMENT Block
    /// History has spoken since 13j (PROVISIONAL P-U4-1).
    static func filed(_ name: String) -> String {
        "Committed \u{201C}\(name)\u{201D} — an immutable saved moment of this take."
    }

    /// The UNNAMED receipt of the three doors that shared one literal —
    /// Takes/Lenses, Canvas and Compare (13s-b U4 hoisted it here, so the
    /// sweep is one line and a pin can hold it).
    static let unnamedReceipt = "Committed — an immutable saved moment of this take."

    static let help = "A name is optional and always editable afterwards — "
        + "Block History's rename door beside the commit"
}

/// The one-line field itself.
struct SavepointNameField: View {
    let tokens: VoiceTokens
    let ask: SavepointNameAsk
    /// Files it. The name is already normalised through the ONE rule, so a
    /// caller can never store a name made of spaces.
    let onFile: (String?) -> Void
    let onCancel: () -> Void

    @State private var typed: String
    @FocusState private var focused: Bool

    /// Room for a real phrase — *"before the AI edit"* — never a search bar
    /// (`TagInlineField.width`'s reasoning, one field over).
    static let width: CGFloat = 260

    init(
        tokens: VoiceTokens, ask: SavepointNameAsk,
        onFile: @escaping (String?) -> Void, onCancel: @escaping () -> Void
    ) {
        self.tokens = tokens
        self.ask = ask
        self.onFile = onFile
        self.onCancel = onCancel
        _typed = State(initialValue: ask.seed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(
                "", text: $typed,
                prompt: Text(tokens.chromeLabel(SavepointNameCopy.prompt(ask.kind))))
                .textFieldStyle(.plain)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
                .focused($focused)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(width: Self.width)
                .background(tokens.card, in: RoundedRectangle(cornerRadius: 7))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(focused ? tokens.accent.opacity(0.45) : tokens.line, lineWidth: 1))
                .onSubmit { onFile(SavepointName.normalized(typed)) }
                // ⎋ inside the field. The popover's own transient dismissal
                // lands in the same place (the host nils the ask), so the two
                // roads cannot disagree about what cancelling means.
                .onExitCommand { onCancel() }
            // P-8: a chrome text that wraps carries a line limit.
            Text(tokens.chromeLabel(SavepointNameCopy.hint(ask.kind)))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: Self.width, alignment: .leading)
        }
        .padding(10)
        .background(tokens.surface)
        // The ⌘K palette's idiom, and its reason: `@FocusState` publishes an
        // edge, so the field takes the keyboard when the presentation has
        // one to give.
        .task { focused = true }
        .help(SavepointNameCopy.help)
    }
}

extension View {
    /// **THE ASK, PRESENTED AT ITS DOOR.** One binding per host, so two
    /// popovers can never be up at once; a dismissal that is not a filing is
    /// a cancel, by construction — the binding goes nil and nothing else
    /// happens.
    func savepointNameAsk(
        _ ask: Binding<SavepointNameAsk?>,
        tokens: VoiceTokens,
        arrowEdge: SwiftUI.Edge = .top,
        onFile: @escaping (SavepointNameAsk, String?) -> Void
    ) -> some View {
        popover(item: ask, arrowEdge: arrowEdge) { pending in
            SavepointNameField(
                tokens: tokens, ask: pending,
                onFile: { name in
                    ask.wrappedValue = nil
                    onFile(pending, name)
                },
                onCancel: { ask.wrappedValue = nil })
        }
    }
}
