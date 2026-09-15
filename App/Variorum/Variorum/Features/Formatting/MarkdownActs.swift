//
//  MarkdownActs.swift
//  Variorum
//
//  Phase 13g, batch 3 (L8 + L9's ruled half) — the FORMATTING ACTS' faces
//  over the pure edit computations in `MarkdownEditing`.
//
//  ── The one architectural claim ──────────────────────────────────────────
//
//  **A formatting act is an ordinary edit, applied through the ordinary
//  input path.** It calls `shouldChangeText` → `replaceCharacters` →
//  `didChangeText` on the surface she is typing in, which is exactly what
//  typing does: the Write editor's delegate routes the verdict, updates
//  `BlockRangeIndex`, records autosave and churn and refuses under a seal or
//  a locked take; a pane's coordinator restyles its lines and hands the new
//  text to its board's autosave. Nothing here writes a row, adds an
//  operation, or touches a schema — under her ruling F-1 the markers ARE the
//  text (`EditorFind`'s precedent, same reasoning, same trio of calls).
//
//  **It can never restructure a note.** Every edit `MarkdownEditing` emits
//  sits inside ONE LINE, and a line sits inside one block (blocks are joined
//  on the editor surface by a single `"\n"`, so a seam always terminates a
//  line). The cross-block arm of the editor's pipeline — which MERGES blocks,
//  the ratified 2026-07-09 merge-then-edit made for a deliberate hand-made
//  selection — is therefore unreachable from here BY CONSTRUCTION, rather
//  than by a pre-check the way find-and-replace needs.
//
//  ── Why the target is the FIRST RESPONDER ────────────────────────────────
//
//  Formatting acts on the text she is typing in, and the object that knows
//  which surface that is is the key window's first responder — the same
//  mechanism AppKit's own Format menu uses. It is NOT a second liveness
//  mechanism (P-3): it decides nothing about which pane is live; it asks who
//  currently holds the keyboard, which liveness has ALREADY decided (a live
//  pane makes itself first responder; `PaneTextAuthority` remains the only
//  authority on which pane that is). The alternative — plumbing a text-view
//  reference out of five boards — is the private-copy class this app has
//  paid for before.
//
//  The target must also be OURS: `MarkdownFormattable` is opted into by the
//  two surface kinds and nothing else, so a rename field, the ⌘K search field
//  or the quick-note pad (all NSTextViews, all editable) can never receive
//  `****` from a menu key.
//

import AppKit
import Foundation
import VariorumCore

/// A text surface the formatting acts may act on. Opted into explicitly by
/// the app's two surface kinds (P-3's deliberate pair) — a field editor is
/// an editable `NSTextView` too, and this is what keeps ⌘B out of it.
protocol MarkdownFormattable: NSTextView {}

@MainActor
enum MarkdownActs {
    // MARK: - The act table (menu order)

    /// One row of the Format menu: a registry id, its act, and — for the
    /// heading family — its children. Declared once and rendered by both the
    /// menu bar and the context menu, so the two can never disagree.
    struct Row {
        let id: CapabilityID
        let act: MarkdownEditing.Act?
        var children: [(title: String, act: MarkdownEditing.Act)] = []
    }

    static let rows: [Row] = [
        Row(id: .formatBold, act: .bold),
        Row(id: .formatItalic, act: .italic),
        Row(id: .formatStrikethrough, act: .strikethrough),
        Row(id: .formatCode, act: .code),
        // 13g batch 4 (L10): the act batch 3 could not have — links were
        // ruled IN (F-5) but had no insertion door, so the only way to make
        // one was to type the brackets.
        Row(id: .formatAddLink, act: .link),
        Row(id: .formatHeading, act: nil, children: [
            ("Heading 1", .heading(level: 1)),
            ("Heading 2", .heading(level: 2)),
            ("Heading 3", .heading(level: 3)),
        ]),
        Row(id: .formatBulletList, act: .bullet),
        Row(id: .formatChecklist, act: .checkbox),
    ]

    /// **13k K8 — the two nesting rows**, a SECOND table beside `rows` and
    /// deliberately so: they are rendered by the Format menu and the context
    /// submenu but NOT by the bottom bar's toolbar (`FormatBar` reads `rows`),
    /// because Tab and ⇧Tab are the primary door and the bar she already
    /// called crowded is eight wide. The split is walk-enforced — these two
    /// declare `.menuBar` + `.contextMenu` and no `.bottomBar` door.
    static let indentRows: [Row] = [
        Row(id: .formatIndent, act: .indent),
        Row(id: .formatOutdent, act: .outdent),
    ]

    /// The heading submenu's rows — read by BOTH the menu bar and the
    /// context menu, so the two can never offer different sizes.
    static var headingRows: [(title: String, act: MarkdownEditing.Act)] {
        rows.first { $0.id == .formatHeading }?.children ?? []
    }

    /// The registry ids the FORMAT CONTEXT SUBMENU renders — walk-asserted
    /// against the `.contextMenu` door set like every other door table. The
    /// submenu is built here rather than by each surface for the same reason
    /// the acts share one applier: seven surfaces rediscovering the rows is
    /// the drift class P-1 exists to kill.
    nonisolated static let contextMenuCapabilities: [CapabilityID] = [
        .formatBold, .formatItalic, .formatStrikethrough, .formatCode,
        .formatAddLink,
        .formatHeading, .formatBulletList, .formatChecklist,
        // 13k K8: the nesting rows ride the submenu too — Tab is the primary
        // door, and a door with no chord that appears in no menu is the WT-1
        // invisibility class.
        .formatIndent, .formatOutdent,
    ]

    /// What the menu door says when a note is open but the keyboard is
    /// somewhere that cannot be formatted (a sidebar row, a read pane, a
    /// sealed note's read-only editor). One sentence, one place — the
    /// registry's own note covers the other case, where nothing is open at
    /// all and the item is honestly grey.
    static let noTargetNote =
        "Click into the text you want to format first — formatting acts on "
        + "the writing surface you're in."

    /// The submenu's own title — not a capability (it names the group, it is
    /// not an act), so it is deliberately undeclared, exactly as the callout
    /// menu's colour rows are.
    static let menuTitle = "Format"

    // MARK: - Targeting

    /// The surface a menu-bar or palette door acts on: the key window's first
    /// responder, when it is one of ours AND editable. Nil ⇒ the door speaks
    /// its declared note instead of acting (P-2 — never a silent key).
    static func target(in window: NSWindow?) -> NSTextView? {
        guard let view = window?.firstResponder as? NSTextView,
              view is MarkdownFormattable, view.isEditable
        else { return nil }
        return view
    }

    /// **THE door every non-context-menu face fires** — the menu bar's (via
    /// `ShellActions.applyFormat`) and, since 13k K7, the bottom bars'
    /// formatting toolbar.
    ///
    /// It exists so the toolbar is not a second brain (P-1): find the surface
    /// holding the keyboard, act on it, and where there is none SPEAK the one
    /// declared note rather than being a dead button (P-2). The context menu
    /// keeps its own door because it already knows its surface — a right-click
    /// names the view it happened in.
    /// `window` defaults to the key window — the door's real input. It is a
    /// PARAMETER only so a pin can drive it: a headless test host's window is
    /// not `NSApp.keyWindow`, and a door whose target could not be named in a
    /// test would have to be trusted rather than proven.
    static func fire(
        _ act: MarkdownEditing.Act, status: StatusCenter,
        in window: NSWindow? = NSApp.keyWindow
    ) {
        guard let textView = target(in: window) else {
            status.speak(noTargetNote)
            return
        }
        apply(act, to: textView)
    }

    // MARK: - Applying

    /// Runs `act` on `textView` through the ordinary input path. Returns
    /// whether anything changed.
    ///
    /// Edits are applied LAST FIRST so every earlier offset stays valid (the
    /// reason the SDK's own finder gives for its reverse ordering), under ONE
    /// undo group so ⌘Z takes back the act she performed rather than one of
    /// its halves. A range the pipeline refuses (a locked take inside a
    /// multi-line selection) is SKIPPED — its refusal has already spoken
    /// through the delegate — and the selection is only re-placed when every
    /// edit landed, because a partly-applied plan's computed selection would
    /// be a guess.
    @discardableResult
    static func apply(_ act: MarkdownEditing.Act, to textView: NSTextView) -> Bool {
        guard textView.isEditable else { return false }
        // Whole lines in, shifted results out — the `MarkdownStyling.restyle`
        // shape, and the whole of the P1 claim: the cost is the lines the
        // selection touches, never the note. The lookup + rebase live in the
        // SHARED door (`MarkdownSurfaceDoors`, the mobile batch-2 parity
        // move) so both platforms run one computation; nil = an empty plan.
        guard let plan = MarkdownSurfaceDoors.plan(
            act, document: textView.string as NSString,
            selection: textView.selectedRange())
        else { return false }

        let undoManager = textView.undoManager
        undoManager?.beginUndoGrouping()
        defer { undoManager?.endUndoGrouping() }

        var applied = 0
        for edit in plan.edits.reversed() {
            guard OrdinaryInputEdit.apply(edit.replacement, over: edit.range, in: textView)
            else { continue }
            applied += 1
        }
        guard applied == plan.edits.count else { return applied > 0 }
        textView.setSelectedRange(plan.selection)
        return true
    }

    // MARK: - L9: the checkbox click

    /// A click landing ON a checkbox's box toggles it — one ordinary edit of
    /// three characters for three, so every offset in the note (the caret
    /// included) is exactly where it was.
    ///
    /// **Mechanism, and why it cannot eat an ordinary caret click:** the
    /// surface asks this BEFORE `super.mouseDown` (which runs AppKit's
    /// selection-tracking loop, so there is no "after" in which to decline),
    /// and the answer is no unless the click's insertion index lands STRICTLY
    /// INSIDE the box's three characters. A click yields a BOUNDARY index, so
    /// the box's own outer boundaries are also produced by clicks on the half
    /// character outside it; accepting those would steal a caret aimed at the
    /// text. Everything else — a read pane, a sealed editor (neither is
    /// editable), any click a character away — falls straight through to the
    /// standing behaviour, click-to-focus included. This is the batch-1
    /// `PaneFocusCatcher` lesson in its other form: that one observes and
    /// never consumes because it has no target of its own; this one consumes
    /// exactly when it has one.
    static func toggleCheckbox(at point: NSPoint, in textView: NSTextView) -> Bool {
        guard textView.isEditable else { return false }
        let string = textView.string as NSString
        guard string.length > 0 else { return false }
        let index = textView.characterIndexForInsertion(at: point)
        guard index >= 0, index <= string.length,
              let edit = MarkdownSurfaceDoors.checkboxToggleEdit(
                  document: string, insertionIndex: index)
        else { return false }

        let selection = textView.selectedRange()
        textView.window?.makeFirstResponder(textView)
        // A refusal (a sealed note reached by a race, a locked take) has
        // already spoken through the delegate; the click is still consumed,
        // because it landed on a box and moving the caret there instead would
        // be answering a different gesture.
        // Act 10 item 11: this is a CLICK's edit, not typing — with the
        // caret elsewhere (the end of the note, after a writing session),
        // β1's caret clearance in `didChangeText` scrolled the view to the
        // caret's line at the absolute bottom. `followingCaret: false`
        // suppresses that for exactly this mutation; the trace and the pin
        // are `CheckboxScrollTests`.
        if OrdinaryInputEdit.apply(
            edit.replacement, over: edit.range, in: textView, followingCaret: false) {
            // The replacement is the same length as what it replaces, so the
            // caret can simply go back where it was.
            textView.setSelectedRange(selection)
        }
        return true
    }

    // MARK: - Act 10 item 12: typed arrows

    /// **`->` becomes → and `<-` becomes ← as you type** (pre-13u Act 10
    /// wave 1, item 12 — ruled). The decision is `TypedArrows`' (one pure
    /// brain, shareable with the phone); this is the Mac's application of
    /// its answer through the ordinary input path — the K5 lead-insertion
    /// shape exactly: `shouldChangeText` → `replaceCharacters` →
    /// `didChangeText`, so a sealed note or a locked take refuses in its
    /// own words with no new refusal code.
    ///
    /// Called by the two writing surfaces AFTER the keystroke's own
    /// insertion lands. **The substitution is applied on its OWN runloop
    /// pass** (`RunLoop.main.perform` — the next pass runs before the next
    /// key event is dispatched): a same-turn edit registers into the
    /// keystroke's own undo group no matter how the coalescing is broken
    /// (measured — one ⌘Z took back the whole typing run), and its own pass
    /// is what makes ⌘Z revert JUST the substitution, restoring the typed
    /// `->` (the smart-quotes convention, her ruled shape). The deferred
    /// application re-reads the caret and the document, so a beaten race
    /// simply declines — the conservative outcome is a missed substitution,
    /// never a wrong edit.
    static func substituteTypedArrow(afterTyping string: Any, in textView: NSTextView) {
        let typed = (string as? String) ?? (string as? NSAttributedString)?.string
        // Only a lone typed terminator can complete a pair — a paste, a
        // find-replacement or an IME composition is not this gesture.
        guard typed == ">" || typed == "-", !textView.hasMarkedText() else { return }
        // The pair's END, captured NOW: under a fast burst the next
        // keystroke can land before the deferred pass runs, and a check
        // against the LIVE caret would then read "> " and decline — a
        // missed substitution under exactly the typing it exists for
        // (measured with synthesized zero-gap keystrokes). The anchor makes
        // the deferred pass ask about the pair where it LANDED; anything
        // typed after it sits past the anchor and shifts automatically when
        // the 2-for-1 replacement lands before it.
        let anchor = textView.selectedRange().location
        RunLoop.main.perform { [weak textView] in
            guard let textView else { return }
            MainActor.assumeIsolated {
                applyTypedArrowSubstitution(in: textView, pairEnd: anchor)
            }
        }
    }

    /// The deferred half: decide (the pure brain) and apply (the ordinary
    /// trio). Internal so the pins can drive it deterministically.
    /// `pairEnd` is the UTF-16 offset just past the typed pair (defaulted
    /// to the live caret for direct calls); the brain re-reads the document
    /// there, so a beaten race — text deleted, the pair edited away —
    /// simply declines.
    static func applyTypedArrowSubstitution(
        in textView: NSTextView, pairEnd: Int? = nil
    ) {
        guard !textView.hasMarkedText() else { return }
        let caret = textView.selectedRange()
        guard caret.location != NSNotFound else { return }
        let end = pairEnd ?? caret.location
        let document = textView.string as NSString
        guard end >= 0, end <= document.length else { return }
        let lines = document.lineRange(for: NSRange(location: max(0, end - 1), length: 0))
        guard end >= lines.location, end <= lines.location + lines.length else { return }
        guard let sub = TypedArrows.substitution(
            line: document.substring(with: lines),
            caret: end - lines.location)
        else { return }
        let range = NSRange(
            location: lines.location + sub.range.lowerBound, length: sub.range.count)
        // Seal the typing run's coalesced action on both sides, so the next
        // keystroke starts its own run rather than joining across the arrow.
        textView.breakUndoCoalescing()
        defer { textView.breakUndoCoalescing() }
        OrdinaryInputEdit.apply(sub.replacement, over: range, in: textView)
        // AppKit shifts any caret past the edit by the length delta itself;
        // a caret exactly at the pair's end lands after the arrow, which is
        // where typing continues.
    }

    // MARK: - K5: ⏎ continues a list

    /// **The ⏎ door** (13k K5, her ruling), shared by both text-surface
    /// kinds so a list behaves the same wherever she is typing.
    ///
    /// `ordinary` is the caller's own `super.insertNewline(_:)` — THE
    /// RATIFIED KEYSTROKE, invoked unchanged. That is the whole safety
    /// claim: the open-tail gesture at the document end, `one_block`'s
    /// newlines-don't-mint, the idle-mint and every refusal all see the
    /// same single typed `"\n"` they always saw, because this never plans
    /// the newline itself. What it adds is a SECOND ordinary insertion of
    /// lead text at the caret the newline left, through the same trio
    /// (`shouldChangeText` → `replaceCharacters` → `didChangeText`) typing
    /// takes — so a sealed note, a locked take and a desynced index all
    /// refuse it in their own words with no new refusal code.
    ///
    /// The two edits ride ONE undo group, so ⌘Z takes back the keystroke
    /// she pressed rather than half of it (`apply`'s rule, same reason).
    ///
    /// **The lead is only inserted if the newline actually landed** — a
    /// refused ⏎ leaves the storage byte-identical, and leading a line that
    /// was never created would be inventing text.
    static func insertNewlineContinuingLists(
        in textView: NSTextView, ordinary: () -> Void
    ) {
        switch listReturn(in: textView) {
        case .ordinary:
            ordinary()

        case .exitList(let lead):
            // The ONE place the keystroke is consumed: no newline at all,
            // just the lead of an item with nothing in it going away.
            deleteWithoutNewline(lead, in: textView)

        case .outdentItem(let unit):
            // 13k K8: an empty NESTED item outdents instead of exiting — the
            // same consumed-keystroke shape, one indent unit instead of the
            // whole lead. At level 0 the case above runs and her K5 ruling is
            // byte-identical.
            deleteWithoutNewline(unit, in: textView)

        case .continueList(let lead):
            let undoManager = textView.undoManager
            undoManager?.beginUndoGrouping()
            defer { undoManager?.endUndoGrouping() }
            let before = (textView.string as NSString).length
            ordinary()
            guard (textView.string as NSString).length == before + 1 else { return }
            let caret = textView.selectedRange()
            guard caret.length == 0, caret.location != NSNotFound else { return }
            OrdinaryInputEdit.apply(lead, over: caret, in: textView)
        }
    }

    /// One ordinary deletion through the ordinary input path, no newline —
    /// the shape both consuming ⏎ verdicts take.
    private static func deleteWithoutNewline(_ range: Range<Int>, in textView: NSTextView) {
        let ns = NSRange(location: range.lowerBound, length: range.count)
        guard ns.length > 0, ns.upperBound <= (textView.string as NSString).length
        else { return }
        OrdinaryInputEdit.apply("", over: ns, in: textView)
    }

    // MARK: - K8: Tab indents a list line, ⇧Tab outdents it

    /// **The Tab door** (13k K8 — her ruling *"we should allow indented lists
    /// and it should happen when you click tab"*, with sitting Q3's ⇧Tab as
    /// the way back).
    ///
    /// **The safety claim is the K5 claim, in the same shape:** the keystroke
    /// is only ours when the caret's own line (or, with a selection, some
    /// affected line) is a LIST line. Everywhere else `ordinary` runs — the
    /// surface's own `super.insertTab`/`insertBacktab`, byte-for-byte the key
    /// it has always been — because an empty plan is exactly the signal that
    /// no list line was touched.
    ///
    /// The edit itself rides `apply`, so it is an ordinary edit like every
    /// other formatting act: autosave, churn, ⌘Z, and a sealed note's own
    /// refusal, with no new refusal code.
    static func indentLists(
        _ act: MarkdownEditing.Act, in textView: NSTextView, ordinary: () -> Void
    ) {
        guard textView.isEditable, apply(act, to: textView) else {
            // Not ours — or ours and REFUSED (a sealed note, a locked take,
            // where the pipeline has already spoken). Either way the standing
            // key runs, and on a surface that refuses an indent it refuses a
            // tab character too, so nothing changes. Pinned both ways.
            ordinary()
            return
        }
    }

    /// The caret line's verdict, in the surface's own offsets. A selection
    /// (⏎ replacing a range) is deliberately ordinary — the ruling is about
    /// a caret at the end of a line.
    static func listReturn(in textView: NSTextView) -> MarkdownEditing.ReturnKey {
        guard textView.isEditable else { return .ordinary }
        let string = textView.string as NSString
        let selection = textView.selectedRange()
        guard selection.length == 0, selection.location != NSNotFound,
              selection.location <= string.length
        else { return .ordinary }
        // The Domain answers in the LINE's offsets; the SHARED door rebases
        // into the note's (the `apply`/`toggleCheckbox` rebasing, one
        // computation for both platforms since the mobile batch-2 move).
        return MarkdownSurfaceDoors.returnVerdict(
            document: string, caret: selection.location)
    }

    // MARK: - L10: the ⌘-click that opens a link

    /// **⌘-click on a link opens it** (her ruling F-5, answering her own
    /// question: *"do you mean click handling in the read mode…?"* — both,
    /// and they differ). On an EDITING surface a plain click has a job
    /// already: it places the caret, and the read-cheap tier's click seeds
    /// that caret's offset. So the modifier IS the wiring she was told the
    /// "face work" was; Read, which has no caret and no gestures, opens on a
    /// plain click instead (`PageFrameNSView`, `ReadingFlowView`).
    ///
    /// Deliberately NOT gated on `isEditable`: opening a link is not an edit,
    /// so a sealed note and the read tier follow one exactly like a live
    /// editor does. And deliberately gated on the SCHEME (`MarkdownLink`) —
    /// an inert address consumes nothing, so the click stays the ordinary
    /// click it looked like.
    static func openLink(at point: NSPoint, in textView: NSTextView) -> Bool {
        guard let url = linkAddress(at: point, in: textView) else { return false }
        return MarkdownLink.open(url)
    }

    /// The address under a point, or nil. Split out from `openLink` so the
    /// GEOMETRY (point → index → span) can be pinned through a real laid-out
    /// surface without a test launching a browser — the same seam the
    /// checkbox click's pure decision gives it.
    static func linkAddress(at point: NSPoint, in textView: NSTextView) -> String? {
        let string = textView.string as NSString
        guard string.length > 0 else { return nil }
        let index = textView.characterIndexForInsertion(at: point)
        guard index >= 0, index <= string.length else { return nil }
        return MarkdownSurfaceDoors.linkAddress(document: string, at: index)
    }

    /// Was this click the link gesture? ⌘ alone, one click — kept here so
    /// both surface kinds ask the same question rather than each spelling
    /// out a modifier mask (the `toggleCheckbox` pairing, same reasoning).
    static func isLinkClick(_ event: NSEvent) -> Bool {
        event.clickCount == 1
            && event.modifierFlags.intersection([.command, .option, .control, .shift])
                == .command
    }

    // MARK: - The context-menu door

    /// The "Format" submenu a surface inserts into its context menu — nil
    /// where the surface cannot be edited, because a door that can never act
    /// in its context is not rendered at all (P-2).
    static func formatMenuItem(for textView: NSTextView) -> NSMenuItem? {
        guard textView is MarkdownFormattable, textView.isEditable else { return nil }
        let item = NSMenuItem(title: menuTitle, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: menuTitle)
        for row in rows + [nil] + indentRows.map(Optional.init) {
            guard let row else {
                submenu.addItem(.separator())
                continue
            }
            let capability = CapabilityRegistry.capability(row.id)
            if let act = row.act {
                submenu.addItem(menuItem(
                    title: capability.verb, act: act, textView: textView))
            } else {
                let parent = NSMenuItem(title: capability.verb, action: nil, keyEquivalent: "")
                let children = NSMenu(title: capability.verb)
                for child in row.children {
                    children.addItem(menuItem(
                        title: child.title, act: child.act, textView: textView))
                }
                parent.submenu = children
                submenu.addItem(parent)
            }
        }
        item.submenu = submenu
        return item
    }

    private static func menuItem(
        title: String, act: MarkdownEditing.Act, textView: NSTextView
    ) -> NSMenuItem {
        let item = NSMenuItem(
            title: title, action: #selector(FormatMenuTrampoline.fire(_:)), keyEquivalent: "")
        let trampoline = FormatMenuTrampoline(act: act, textView: textView)
        item.target = trampoline
        item.representedObject = trampoline  // retains it for the menu's life
        return item
    }
}

/// The context menu's target object (the `StructuralMenuTrampoline` pattern:
/// `NSMenuItem` holds its target weakly, so the item retains this through
/// `representedObject`). It holds its text view weakly for the same reason
/// every other controller here does — a menu outliving its surface must do
/// nothing, not crash.
@MainActor
private final class FormatMenuTrampoline: NSObject {
    private let act: MarkdownEditing.Act
    private weak var textView: NSTextView?

    init(act: MarkdownEditing.Act, textView: NSTextView) {
        self.act = act
        self.textView = textView
    }

    @objc func fire(_ sender: Any?) {
        guard let textView else { return }
        MarkdownActs.apply(act, to: textView)
    }
}
