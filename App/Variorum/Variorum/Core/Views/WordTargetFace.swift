//
//  WordTargetFace.swift
//  Variorum
//
//  13b Stage 4, Batch 4F (S4-28.1, ledger N36) — the per-post word
//  target's ONE face, riding the word-count label BOTH bars already carry
//  (Write's CommitBar and the Takes/Lenses bar — R118 parity of
//  prominence, zero new bar width on the crowded-bar surfaces N15/N35
//  fought over). Display/progress ONLY — the ratified word_target
//  semantics, mirrored per post.
//
//  **13u4 UNIT S2 — HER ITEM 1'S SECOND HALF.** Her words: *"it would be
//  nice if the word counter thing at the bottom could condense as well - I
//  like that it offers to set a word count target, so I want to keep that
//  functionality, but maybe a little icon meant to represent count or
//  something could be an optional condensed view. Or show only note, only
//  block, or only icon. I don't necessarily want an appearance setting - I
//  want these to be changed by clicking on them."*
//
//  So the counter CYCLES on a click — full → only the note → only this
//  block → just an icon — and the choice is remembered, local to this Mac
//  and global to every note (the masthead stamp's own shape, one file
//  over). **Her click took the gesture the target setter used to have**, so
//  the setter moved to the counter's CONTEXT MENU, where it is offered in
//  EVERY face including the icon: *"I like that it offers to set a word
//  count target, so I want to keep that functionality"* is a keep, and a
//  keep that survives only in three faces of four would not be one. The
//  same menu lists the four faces with a ✓ on the current one, so the cycle
//  is discoverable rather than folklore — which is the one thing a bare
//  click cannot do. (The alternatives are QUESTIONS #132.)
//
//  The file moved from `Features/Editor/` to `Core/Views/` in the same
//  breath: two features render it, and CLAUDE.md's placement rule sends
//  such a component to the shared home at the next touch of work on it.
//

import SwiftUI
import VariorumCore

/// **The counter's parts**, as each bar words them — never a pre-composed
/// string, because the FACE decides which parts are said.
///
/// The words themselves stay each bar's own (*"12w block"* in Write, *"12w
/// take"* on the boards, *"1,240w in note"* against *"1,240w note"*): this
/// unit condenses the counter, and re-wording it would be a second change
/// hiding inside the first.
nonisolated struct WordCounts: Equatable {
    /// The caret's own unit — a block in Write, a take on the boards.
    var unit: String?
    /// The selection, where a surface has one (Write only).
    var selected: String?
    /// The note's total.
    var note: String?
    /// What the unit IS, for the menu's own row (*"Only this block"* /
    /// *"Only this take"*). Never shown beside the counts.
    var unitNoun: String = "block"

    /// Whether there is anything at all to say — the exact condition both
    /// bars used to express as `wordCountLabel != nil`, so a bar with no
    /// counts still renders nothing at all.
    var hasAnything: Bool { unit != nil || selected != nil || note != nil }
}

/// **The counter's resting face** — her four, in her order.
///
/// Pure, at file scope and `CaseIterable`, so the cycle and the menu's rows
/// are one rule (`StampFace`'s own shape, one file over).
nonisolated enum CountsFace: String, CaseIterable, Sendable {
    /// Everything the bar knows — the shipped face, and the default.
    case full
    /// *"only note"*.
    case note
    /// *"only block"* (a take, on the boards).
    case block
    /// *"only icon"* — and the target door is still on it.
    case icon

    /// Her cycle, in her order: *"Or show only note, only block, or only
    /// icon"*, and round again to the full counts.
    var next: CountsFace {
        switch self {
        case .full: .note
        case .note: .block
        case .block: .icon
        case .icon: .full
        }
    }

    /// **Where the bar is NARROW** (the folded flat row, the book box's
    /// footer), a face that is still the full label has to give — that is
    /// C-6's own verdict, which shipped as a second view. A face she has
    /// already condensed is left exactly as she chose it: the width may
    /// shorten the counter, never lengthen it.
    var narrowed: CountsFace { self == .full ? .note : self }

    /// The face that can actually be DRAWN from these counts. A face whose
    /// parts are all absent falls through — `block` with the caret nowhere,
    /// `note` before the total lands — so the door never disappears under
    /// her (and never draws an empty label).
    func drawable(for counts: WordCounts) -> CountsFace {
        switch self {
        case .full: counts.hasAnything ? .full : .icon
        case .note: counts.note != nil ? .note : CountsFace.block.drawable(for: counts)
        case .block: counts.unit != nil ? .block : (counts.note != nil ? .note : .icon)
        case .icon: .icon
        }
    }

    /// What this face says, from these parts. **nil is the icon** — the one
    /// face that says nothing in words.
    func label(_ counts: WordCounts) -> String? {
        switch self {
        case .full:
            let parts = [counts.unit, counts.selected, counts.note].compactMap { $0 }
            return parts.isEmpty ? nil : parts.joined(separator: " \u{B7} ")
        case .note: return counts.note
        case .block: return counts.unit
        case .icon: return nil
        }
    }

    /// **LOCAL to this Mac, GLOBAL to every note** — the `mastheadStampFace`
    /// class exactly (her one sentence covers both faces: *"I want these to
    /// be changed by clicking on them"*), and never synced: how she likes a
    /// bar to look is this machine's taste, not document semantics. Zero
    /// schema, zero `setting` key, the lockstep marker stays 8.
    ///
    /// **Its defaults family** (`KnownIssuesAndTechDebt` rows 42/43): NOT a
    /// per-note key, so row 43's outlives-the-note family does not apply —
    /// one value, nothing to evict. It DOES share row 42's harness hazard
    /// (the test host IS `io.lduarte.Variorum.debug`), and the seam is
    /// SwiftUI's own: a pin mounts under `.defaultAppStorage(<a scrubbed
    /// suite>)`.
    static let key = "barCountsFace"

    /// A stored value that is not one of the four reads as `.full` — every
    /// local key in this app takes this posture.
    static func remembered(_ defaults: UserDefaults = .standard) -> CountsFace {
        defaults.string(forKey: key).flatMap(CountsFace.init(rawValue:)) ?? .full
    }
}

/// **THE COUNTER'S CONTEXT MENU, AS DATA** — the `CommitBar.structuralRows`
/// pattern (13u4 UNIT S1's own reason: a private `@ViewBuilder` is
/// unreachable from a test, and *"the target door is offered in every
/// face"* is a claim that has to be checkable).
///
/// The rows the view renders ARE this list, so what a pin reads and what
/// she presses cannot drift apart.
nonisolated enum CountsMenu {
    enum Act: Equatable {
        /// Set or change the note's word target — **her keep**, in every
        /// face.
        case target
        case clearTarget
        case face(CountsFace)

        /// Whether this act belongs to the TARGET half of the menu — the
        /// view draws its one divider where that half ends.
        var isTarget: Bool { self == .target || self == .clearTarget }
    }

    struct Row: Equatable {
        let title: String
        let act: Act
        /// Whether this row wears the ✓ (the face she is in).
        var checked = false
    }

    static func rows(face: CountsFace, target: Int?, unitNoun: String) -> [Row] {
        var rows: [Row] = [
            Row(title: target == nil
                ? WordTargetFaceCopy.setTargetItem
                : WordTargetFaceCopy.changeTargetItem,
                act: .target),
        ]
        if target != nil {
            rows.append(Row(title: WordTargetFaceCopy.clearTargetItem, act: .clearTarget))
        }
        for option in CountsFace.allCases {
            rows.append(Row(
                title: WordTargetFaceCopy.faceItem(option, unitNoun: unitNoun),
                act: .face(option),
                checked: option == face))
        }
        return rows
    }
}

struct WordTargetFace: View {
    let tokens: VoiceTokens
    /// The bar's counts, in the bar's own words.
    let counts: WordCounts
    /// The post's total words (the progress numerator; nil = unknown yet).
    let words: Int?
    /// The stored target (nil = none).
    let target: Int?
    /// Runs the op (`setPostWordTarget`) — refusals speak via the caller's
    /// standing error door.
    let onSet: (Int?) async -> Void
    /// True where the bar is narrow (the folded row, the book box's
    /// footer): a FULL face condenses to the note's total there, and any
    /// face she has already condensed stands.
    var narrowed = false

    @AppStorage(CountsFace.key) private var face: CountsFace = .full
    @State private var shown = false
    @State private var field = ""
    @State private var parseError: String?

    private var drawn: CountsFace {
        (narrowed ? face.narrowed : face).drawable(for: counts)
    }

    var body: some View {
        Button {
            // **HER MANDATE** (item 1): the click condenses. The target
            // setter it displaced is on the context menu below, in every
            // face — never in Settings.
            face = face.next
        } label: {
            // R11's register preserved: the counts stay the prominent
            // accent-colored part of the surface; the face adds only the
            // progress segment.
            Group {
                if let label {
                    Text(tokens.chromeLabel(label))
                } else {
                    // *"a little icon meant to represent count or
                    // something"*. `text.word.spacing` reads as words rather
                    // than as numbers — and `number` was rejected outright:
                    // `#` is the masthead's TAG door in this app, and one
                    // glyph meaning two things is the confusion the whole
                    // registry exists to avoid.
                    Text(Image(systemName: "text.word.spacing"))
                }
            }
            .font(tokens.small.weight(.semibold))
            .foregroundStyle(tokens.accent)
            .lineLimit(1)
            // 13u4 ladder round 1, R1-2 (the pre-ladder walk's flagged item):
            // a plain-style button's hit area is exactly its label's bounds,
            // which at the ICON face is one small glyph. The negative inset
            // widens the CLICKABLE shape a few points on every side —
            // hit-testing only, zero layout movement (`contentShape` never
            // measures), so nothing on the bar moves by a point. Honestly
            // un-pinnable: "the target feels small" has no red-on-old, so this
            // is a comfort, verified by eye rather than by a test.
            .contentShape(Rectangle().inset(by: -6))
        }
        .buttonStyle(.plain)
        // The hover carries the WHOLE fact in every face — which is what
        // makes a collapse a collapse rather than a loss (the masthead
        // clock's own rule, one file over).
        .help(WordTargetFaceCopy.help(whole: wholeLabel))
        .accessibilityLabel(label ?? wholeLabel ?? WordTargetFaceCopy.iconLabel)
        .contextMenu { menu }
        .popover(isPresented: $shown, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Word target — this note").font(.headline)
                TextField(WordTargetFaceCopy.fieldPrompt, text: $field)
                    .frame(width: 220)
                    .onSubmit { save() }
                Text("A target shows progress beside the word counts. "
                    + "It is a measure, never a wall — nothing refuses at the boundary.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 220, alignment: .leading)
                if let parseError {
                    Text(parseError).font(.caption).alarmVoice()
                }
                HStack {
                    Button("Clear") {
                        shown = false
                        Task { await onSet(nil) }
                    }
                    Spacer()
                    Button("Set") { save() }
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding(12)
        }
    }

    /// **The target door, in EVERY face** (her keep), beside the four faces
    /// themselves — so the cycle is something she can SEE rather than
    /// something she has to discover by clicking.
    @ViewBuilder private var menu: some View {
        let rows = CountsMenu.rows(face: face, target: target, unitNoun: counts.unitNoun)
        ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
            if case .face = row.act, index > 0, rows[index - 1].act.isTarget {
                Divider()
            }
            Button {
                run(row.act)
            } label: {
                // The ✓ grammar the rest of the chrome uses for "this is the
                // one" (R12/R22's own mark).
                Text(row.checked ? "\u{2713} \(row.title)" : row.title)
            }
        }
    }

    private func run(_ act: CountsMenu.Act) {
        switch act {
        case .target: openTarget()
        case .clearTarget: Task { await onSet(nil) }
        case .face(let option): face = option
        }
    }

    /// The words this face draws, with the target's progress where there is
    /// one. The icon face draws none — and its progress, like its counts,
    /// is on the hover.
    private var label: String? { worded(drawn) }

    /// Everything the bar knows, whatever face is drawn — the hover's own
    /// first half, and what a screen reader is told the control IS.
    private var wholeLabel: String? { worded(.full) }

    private func worded(_ face: CountsFace) -> String? {
        guard let base = face.label(counts) else { return nil }
        guard let target, target > 0 else { return base }
        let segment = WordTargetFaceCopy.progressSegment(words: words ?? 0, target: target)
        return base.isEmpty ? segment : "\(base) \u{B7} \(segment)"
    }

    private func openTarget() {
        field = target.map(String.init) ?? ""
        parseError = nil
        shown = true
    }

    private func save() {
        guard let parsed = ExtentInput.parse(field) else {
            parseError = WordTargetFaceCopy.parseError
            return
        }
        shown = false
        Task { await onSet(parsed.intValue) }
    }
}
