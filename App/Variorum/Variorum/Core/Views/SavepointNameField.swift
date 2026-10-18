//
//  SavepointNameField.swift
//  Variorum (Mac — `Core/Views`, the shared home)
//
//  13u3 UNIT D — **the name at the commit door** (master plan item 14, her
//  words: *"an optional name at the manual-commit door, enter-to-skip keeps
//  ⌘S instant"*; the rename half is her ruling R-13u3-1).
//
//  ── ONE FIELD, EVERY DOOR ────────────────────────────────────────────────
//  Seven hosts name a saved moment: ⌘S in Write (its bar, and the prose when
//  the doors live in the sidebar's note box — the book's editing modes), in
//  Takes/Lenses (one bar), in Write's take panel, in Canvas and in Compare,
//  and the rename door beside a savepoint in Block History. They are many
//  places, one gesture, so they compose ONE view, ONE leave rule and ONE
//  modifier (`savepointNameAsk`) — the placement rule's own letter, since
//  more than one feature consumes it.
//
//  ── VX-347 — ⌘S ALWAYS COMMITS; ONLY ⎋ DOESN'T ──────────────────────────
//  Her report (2026-10-14): *"command S should always commit your take even
//  without an extra keystroke to enter (but if you click escape, then that
//  can deliberately not save. the keyboard shortcut is lying right now since
//  it's really command S enter)."* Her ruling, superseding QUESTIONS
//  #121(b): the optional name field stays, and **every way of leaving it
//  except ⎋ FILES the commit** — named with what was typed, unnamed if
//  nothing was: ⏎, a click away, going back to the take to type on, the
//  window (or the host) going away. ⎋ alone is the deliberate "don't save".
//  (⌘S pressed again while its field is up leaves the field too — so it
//  files — PROVISIONAL P-VX347-2.) The RENAME door is not ⌘S: there ⏎
//  renames and every other leave keeps the name as it was, exactly as
//  before (P-VX347-3).
//
//  ── WHERE A LEAVE IS HEARD (one settle per field, whichever road is first)
//  · ⏎ and ⎋ — the field's own keys (`onSubmit`, `onExitCommand`; ⎋ is
//    settled BEFORE the popover closes, so no closing road can file it).
//  · The popover's own CLOSING — `NSPopover.willCloseNotification` for the
//    popover whose content window is this field's
//    (`SavepointPopoverClosingWatcher`, on `CommentPanelHostWatcher.isHost` —
//    VX-179's MEASURED road: SwiftUI never tears a dismissed popover's
//    content down, so `.onDisappear` on popover content never fires). Every
//    dismissal ends there — a click away (AppKit's transient monitor), the
//    binding going nil, the host or its window going. A closing heard while
//    AppKit dispatches a fresh ⎋ addressed to this popover IS ⎋
//    (`SavepointNameLeave.closing(during:popoverWindow:)`), so a popover
//    that cancels itself on ⎋ can never file.
//  · The HOST's ask moving (`.onChange`) — nil'd or replaced while its field
//    was still open (⌘S again; a model that let go).
//  · The HOST going (`.onDisappear` on the host — which does fire): a mode
//    switch, a closed note, a closing window or sheet.
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

import AppKit
import SwiftUI
import VariorumCore

/// **A PENDING NAME** — which savepoint is being named, and what the field
/// opens with. A value, so a pin can hold the seeding and the identity
/// without presenting anything.
nonisolated struct SavepointNameAsk: Identifiable, Equatable {
    enum Kind: Equatable {
        /// ⌘S: the savepoint does not exist yet. Leaving the field files
        /// it, named or not — every way but ⎋ (VX-347).
        case newSavepoint
        /// Block History's rename door: the savepoint exists (R-13u3-1).
        case rename
    }

    var kind: Kind
    /// The row the ask belongs to — the TAKE for a new savepoint, the
    /// SAVEPOINT for a rename. **The filer acts on THIS, never on whatever
    /// the caret or the ring holds when the field leaves** (VX-347: a click
    /// away into another block is a way of leaving, so the take that files
    /// must be the one ⌘S asked about).
    var targetID: String
    /// What the field opens with: empty at the commit door (a savepoint is
    /// born unnamed unless she says otherwise), the current name at the
    /// rename door (renaming starts from what is there — and clearing it is
    /// how a name is removed).
    var seed: String = ""
    /// The POST the target take lives in, where a host's takes cross posts
    /// (Compare: the filer flushes that post's own coordinator). Empty
    /// everywhere else — the host's one post.
    var context: String = ""

    var id: String { "\(kind == .rename ? "rename" : "new"):\(targetID)" }

    static func naming(variantID: String, context: String = "") -> Self {
        SavepointNameAsk(kind: .newSavepoint, targetID: variantID, context: context)
    }

    static func renaming(_ commit: CommitPoint) -> Self {
        SavepointNameAsk(
            kind: .rename, targetID: commit.id,
            seed: SavepointRowFace.name(commit) ?? "")
    }
}

/// **HOW THE FIELD WAS LEFT — and whether that files** (VX-347, her ruling).
/// Pure, so the whole contract is one table a pin can read.
nonisolated enum SavepointNameLeave: Equatable, Sendable {
    /// ⏎ in the field.
    case returnKey
    /// ⎋ (or ⌘., the same Exit command) — the deliberate "don't save".
    case escape
    /// Every other way: a click away, going back to the take, the window or
    /// the host going, the app switching away, ⌘S again.
    case away

    /// Whether leaving this way files the ask. ⌘S's field files on every
    /// leave but ⎋; the rename door renames on ⏎ only and keeps the name as
    /// it was on any other leave (its shipped "⎋ leaves it as it was",
    /// untouched — P-VX347-3).
    func files(_ kind: SavepointNameAsk.Kind) -> Bool {
        switch self {
        case .returnKey: true
        case .escape: false
        case .away: kind == .newSavepoint
        }
    }

    /// ⎋'s key code (`kVK_Escape`).
    static let escapeKeyCode: UInt16 = 53
    /// How old the event AppKit is dispatching may be and still be the
    /// reason a popover is closing. A closing caused BY a key is heard
    /// synchronously inside that key's dispatch (milliseconds); a ⎋ pressed
    /// seconds earlier elsewhere is not why anything closes now.
    static let causeWindow: TimeInterval = 1

    /// **The field's popover closing with no key of the field's own:** ⎋
    /// when the event AppKit is dispatching IS a fresh ⎋ (or ⌘.) delivered
    /// to THIS popover — its own window, or the window it hangs from (AppKit
    /// keeps the main window key and forwards into its popover) — which is
    /// the popover cancelling itself; `away` for everything else (a
    /// mouse-down outside it, a chord, a ⎋ meant for some other window, a
    /// stale event, no event at all). The one bias is the safe one: only ⎋
    /// can keep a commit from filing.
    static func closing(
        keyDown: Bool, keyCode: UInt16, characters: String?,
        modifiers: NSEvent.ModifierFlags, age: TimeInterval,
        addressedToThisPopover: Bool
    ) -> Self {
        guard keyDown, addressedToThisPopover, age >= 0, age < causeWindow else { return .away }
        let chord = modifiers.intersection(.deviceIndependentFlagsMask)
            .subtracting([.capsLock, .numericPad, .function])
        if keyCode == escapeKeyCode, chord.isEmpty { return .escape }
        if characters == ".", chord == [.command] { return .escape }
        return .away
    }

    /// The same rule over the event AppKit is dispatching right now, for the
    /// popover whose content lives in `popoverWindow`.
    @MainActor
    static func closing(during event: NSEvent?, popoverWindow: NSWindow?) -> Self {
        guard let event, event.type == .keyDown, let popoverWindow else { return .away }
        let addressed = event.windowNumber == popoverWindow.windowNumber
            || (popoverWindow.parent.map { event.windowNumber == $0.windowNumber } ?? false)
        return closing(
            keyDown: true, keyCode: event.keyCode,
            characters: event.charactersIgnoringModifiers,
            modifiers: event.modifierFlags,
            age: ProcessInfo.processInfo.systemUptime - event.timestamp,
            addressedToThisPopover: addressed)
    }
}

/// **The field's popover is closing** — `NSPopover.willCloseNotification`
/// for the popover whose content window is this view's own (the identity
/// rule is `CommentPanelHostWatcher.isHost`, VX-179's measured road: every
/// dismissal ends here — a click away, the binding going nil, the host or
/// its window going — and SwiftUI never tears popover content down, so
/// `.onDisappear` there never fires). Hands the closing its window, so a ⎋
/// can be told apart from every other way out.
struct SavepointPopoverClosingWatcher: NSViewRepresentable {
    let onClosing: (NSWindow) -> Void

    func makeNSView(context: Context) -> WatcherView {
        let view = WatcherView()
        view.onClosing = onClosing
        return view
    }

    func updateNSView(_ nsView: WatcherView, context: Context) {
        nsView.onClosing = onClosing
    }

    final class WatcherView: NSView {
        var onClosing: ((NSWindow) -> Void)?
        private var observer: NSObjectProtocol?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let observer {
                NotificationCenter.default.removeObserver(observer)
                self.observer = nil
            }
            guard window != nil else { return }
            observer = NotificationCenter.default.addObserver(
                forName: NSPopover.willCloseNotification, object: nil, queue: .main
            ) { [weak self] note in
                // Read before the hop: the notification itself is not
                // Sendable; the popover (a main-actor class) is.
                let closing = note.object as? NSPopover
                MainActor.assumeIsolated {
                    guard let self, let window = self.window,
                          CommentPanelHostWatcher.isHost(closing, ofPanelIn: window)
                    else { return }
                    self.onClosing?(window)
                }
            }
        }
        // (No `deinit`: the view leaves its window before it dies, and
        // `viewDidMoveToWindow` with a nil window removes the observer — the
        // `CommentPanelHostWatcher` note, same reason.)
    }
}

/// **ONE FIELD'S LEAVING, SETTLED EXACTLY ONCE** (VX-347). Every road a
/// leave can arrive by — the field's two keys, the popover's closing, the
/// host's ask moving, the host going — reports here; the first report
/// decides, every later one for the same field is a no-op. So ⏎ followed by
/// the popover's own close files once, and ⎋ followed by it files nothing.
///
/// One per host (the modifier's `@State`), holding at most one open field.
/// A field stays SETTLED until the host's ask moves away from it, so a late
/// report for a field already left can never re-open it; a fresh ⌘S is a
/// fresh field because the host's ask changes (nil → the ask) to show it.
@MainActor
final class SavepointNameLeaving {
    private struct Open {
        let ask: SavepointNameAsk
        var typed: String
        var left: SavepointNameLeave?
    }

    private var open: Open?
    /// The last field left, kept so a closing heard AFTER the host's ask
    /// already moved on is recognised as that field's, not adopted as new.
    private var lastLeft: SavepointNameAsk?

    /// What the host does with a leave that files: `onFile(ask, name)` —
    /// the name already through the ONE rule (`SavepointName`), so a caller
    /// can never store a name made of spaces.
    typealias File = (SavepointNameAsk, String?) -> Void
    /// Lets go of the host's ask, if it still holds this one.
    typealias Clear = (SavepointNameAsk) -> Void

    /// How the open field was left, if it was (a pin's read).
    var openLeave: SavepointNameLeave? { open?.left }

    /// The open field for `ask` — adopting it when none is open and it is
    /// not the field just left (a host that appeared with its ask already
    /// set, before any change could be heard).
    private func field(for ask: SavepointNameAsk) -> Bool {
        if open == nil, lastLeft != ask {
            open = Open(ask: ask, typed: ask.seed, left: nil)
        }
        return open?.ask == ask
    }

    /// The field's text, kept as it is typed (synchronously — the field's
    /// own binding writes it), so a leave that arrives by a click carries
    /// exactly what she typed.
    func typed(_ text: String, for ask: SavepointNameAsk) {
        guard field(for: ask) else { return }
        open?.typed = text
    }

    /// **A leave.** Answers whether this report decided the field — false
    /// for a field already left (or one this host is not showing).
    @discardableResult
    func leave(
        _ ask: SavepointNameAsk, _ way: SavepointNameLeave,
        clear: Clear, file: File
    ) -> Bool {
        guard field(for: ask), let current = open, current.left == nil else { return false }
        open?.left = way
        lastLeft = ask
        clear(ask)
        if way.files(ask.kind) {
            file(ask, SavepointName.normalized(current.typed))
        }
        return true
    }

    /// **The host's ask moved** (`.onChange`): a field still open for the
    /// ask it moved FROM is left `way` (the presenter passes `.away` — a ⎋
    /// always settles first, at the field or at the popover's closing) — and
    /// the ask it moved TO opens fresh.
    func hostAskChanged(
        from old: SavepointNameAsk?, to new: SavepointNameAsk?,
        way: SavepointNameLeave, clear: Clear, file: File
    ) {
        // `field(for:)` adopts an ask this box never heard open (a host that
        // appeared holding it), so even that field is left, never dropped.
        if let old, field(for: old), open?.left == nil {
            leave(old, way, clear: clear, file: file)
        }
        if let new {
            open = Open(ask: new, typed: new.seed, left: nil)
            if lastLeft == new { lastLeft = nil }
        } else {
            open = nil
        }
    }

    /// **The host went** (`.onDisappear` on the host): its open field, if
    /// it is still open, is left away.
    func hostLeft(holding ask: SavepointNameAsk?, clear: Clear, file: File) {
        guard let ask else { return }
        leave(ask, .away, clear: clear, file: file)
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

    /// **VX-347 — the commit door's two-key line says the new contract:**
    /// leaving commits (⏎ or a click away), ⎋ doesn't. The vocabulary is
    /// COMMIT (R-13s-31). PROVISIONAL words (P-VX347-4 — her copy pass).
    static let newHint = "\u{23CE} or clicking away commits it \u{00B7} \u{238B} doesn't. "
        + "An empty name is fine."
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

/// The one-line field itself. It decides nothing about filing: it reports
/// its text as it is typed and its two keys as leaves, and the host's
/// `SavepointNameLeaving` decides (VX-347).
struct SavepointNameField: View {
    let tokens: VoiceTokens
    let ask: SavepointNameAsk
    /// Every edit, as it lands.
    let onTyped: (String) -> Void
    /// ⏎ (`.returnKey`) and ⎋ (`.escape`) — the field's own two leaves.
    let onLeave: (SavepointNameLeave) -> Void

    @State private var typed: String
    @FocusState private var focused: Bool

    /// Room for a real phrase — *"before the AI edit"* — never a search bar
    /// (`TagInlineField.width`'s reasoning, one field over).
    static let width: CGFloat = 260

    init(
        tokens: VoiceTokens, ask: SavepointNameAsk,
        onTyped: @escaping (String) -> Void,
        onLeave: @escaping (SavepointNameLeave) -> Void
    ) {
        self.tokens = tokens
        self.ask = ask
        self.onTyped = onTyped
        self.onLeave = onLeave
        _typed = State(initialValue: ask.seed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(
                "", text: Binding(
                    get: { typed },
                    set: { text in
                        typed = text
                        onTyped(text)
                    }),
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
                .onSubmit {
                    onTyped(typed)
                    onLeave(.returnKey)
                }
                // ⎋ inside the field — settled as ⎋ BEFORE the popover
                // closes, so the closing that follows finds the field already
                // left and files nothing.
                .onExitCommand { onLeave(.escape) }
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

/// **THE ASK, PRESENTED AT ITS DOOR — and every way of leaving it heard.**
private struct SavepointNameAskPresenter: ViewModifier {
    @Binding var ask: SavepointNameAsk?
    let tokens: VoiceTokens
    let arrowEdge: SwiftUI.Edge
    let onFile: (SavepointNameAsk, String?) -> Void

    @State private var leaving = SavepointNameLeaving()

    func body(content: Content) -> some View {
        let leaving = leaving
        let file = onFile
        let binding = $ask
        let clear: SavepointNameLeaving.Clear = { left in
            if binding.wrappedValue == left { binding.wrappedValue = nil }
        }
        return content
            .popover(item: $ask, arrowEdge: arrowEdge) { pending in
                SavepointNameField(
                    tokens: tokens, ask: pending,
                    onTyped: { leaving.typed($0, for: pending) },
                    onLeave: { way in leaving.leave(pending, way, clear: clear, file: file) })
                    // The popover's own closing — the one moment every
                    // dismissal road shares (VX-179's measured watcher).
                    .background(SavepointPopoverClosingWatcher(onClosing: { window in
                        leaving.leave(
                            pending,
                            .closing(during: NSApp.currentEvent, popoverWindow: window),
                            clear: clear, file: file)
                    }))
            }
            // The host's ask moving while its field is open (⌘S again; a
            // model that let go): never ⎋ — a ⎋ settles at the field or at
            // the popover's closing, both of which come first.
            .onChange(of: ask) { old, new in
                leaving.hostAskChanged(from: old, to: new, way: .away, clear: clear, file: file)
            }
            .onDisappear {
                leaving.hostLeft(holding: binding.wrappedValue, clear: clear, file: file)
            }
    }
}

extension View {
    /// **THE ASK, PRESENTED AT ITS DOOR.** One binding per host, so two
    /// popovers can never be up at once. `onFile` runs once per field, for
    /// every leave the rule files (VX-347: at the commit door, every leave
    /// but ⎋; at the rename door, ⏎ only) — always for the ask it was given,
    /// so a host files `pending.targetID`, never a caret read at filing time.
    func savepointNameAsk(
        _ ask: Binding<SavepointNameAsk?>,
        tokens: VoiceTokens,
        arrowEdge: SwiftUI.Edge = .top,
        onFile: @escaping (SavepointNameAsk, String?) -> Void
    ) -> some View {
        modifier(SavepointNameAskPresenter(
            ask: ask, tokens: tokens, arrowEdge: arrowEdge, onFile: onFile))
    }
}
