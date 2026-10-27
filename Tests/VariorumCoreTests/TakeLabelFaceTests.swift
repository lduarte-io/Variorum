import Foundation
import Testing
@testable import VariorumCore

/// **VX-352 — the take card keeps the label's own words** (`TakeLabelFace`; the run
/// record `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 2a RECORD,
/// PROVISIONAL MB-4). Her capture (the VX-336 U5 STAGE RUN, step 12): in Terminal at
/// a margin-grid card's width the header read "choose claude-code · e…" — the client's
/// name whole, "english" (what tells the takes apart) gone.
///
/// The card draws the label's two parts through `TakeLabelLine`, whose layout asks
/// `allocate` for each part's width; each part then tail-truncates inside its own. A
/// monospace face (Terminal's) makes that exact in COLUMNS, so `shown` below is the
/// face's arithmetic with one column per character and a `Text`'s tail truncation
/// ("…" in the last column). RED ON OLD: the old face is the reading-order
/// allocation — one run cut at its tail — which reproduces the capture exactly.
@Suite("VX-352 — a narrow take card keeps the label's own part; the client name yields")
struct TakeLabelFaceTests {
    /// A `Text`'s tail truncation in a monospace face, in columns.
    private func truncated(_ text: String, _ columns: Int) -> String {
        if text.count <= columns { return text }
        return columns <= 0 ? "" : String(text.prefix(columns - 1)) + "\u{2026}"
    }

    /// What the card shows at `columns` — the two parts at the widths
    /// `allocate` gives them, each truncated inside its own.
    private func shown(_ label: String, columns: Int) -> String {
        let parts = TakeLabelFace.parts(label)
        let widths = TakeLabelFace.allocate(
            available: Double(columns), yielding: Double(parts.yielding?.count ?? 0), kept: Double(parts.kept.count))
        return truncated(parts.yielding ?? "", Int(widths.yielding)) + truncated(parts.kept, Int(widths.kept))
    }

    // MARK: - Her case (red on old)

    @Test func terminalsNarrowCardKeepsEnglishAndLetsTheClientNameYield() {
        let label = "claude-code \u{00B7} english"
        #expect(label.count == 21)
        // The capture's width: the old face showed "claude-code · e…" here.
        #expect(shown(label, columns: 16) == "claud\u{2026} \u{00B7} english",
                "the label's own part kept whole: \(shown(label, columns: 16))")
        #expect(shown(label, columns: 16) != "claude-code \u{00B7} e\u{2026}", "never the capture's face")
        // As the card narrows, the client's name gives way first, to its last column.
        #expect(shown(label, columns: 12) == "c\u{2026} \u{00B7} english")
        #expect(shown(label, columns: 11) == "\u{2026} \u{00B7} english")
        #expect(shown(label, columns: 10) == " \u{00B7} english", "the name gone, the own part whole")
        // Only past that does the own part itself give way.
        #expect(shown(label, columns: 8) == " \u{00B7} engl\u{2026}")
        // Room for it all (Study's case): the whole label, exactly as before.
        #expect(shown(label, columns: 21) == label)
        #expect(shown(label, columns: 40) == label)
    }

    /// The legacy form (`‹client› · suggested · ‹label›`, takes labelled before
    /// VX-267): the `suggested` word yields with the name, so "english" is kept.
    @Test func theLegacyFormKeepsItsOwnLabelToo() {
        let label = "claude-code \u{00B7} suggested \u{00B7} english"
        #expect(TakeLabelFace.parts(label)
                == .init(yielding: "claude-code \u{00B7} suggested", kept: " \u{00B7} english"))
        #expect(shown(label, columns: 16) == "claud\u{2026} \u{00B7} english")
        #expect(shown(label, columns: 33) == label)
    }

    // MARK: - The split (pure)

    @Test func thePartsTable() {
        let dot = " \u{00B7} "
        // VX-267's form: the name yields, the separator rides with the kept words.
        #expect(TakeLabelFace.parts("claude-code\(dot)english") == .init(yielding: "claude-code", kept: "\(dot)english"))
        // A client's own label holding the separator is kept whole as its own part.
        #expect(TakeLabelFace.parts("claude-code\(dot)english\(dot)formal")
                == .init(yielding: "claude-code", kept: "\(dot)english\(dot)formal"))
        // No separator: one kept part — today's face (a bare client name, her own label).
        #expect(TakeLabelFace.parts("claude-code") == .init(yielding: nil, kept: "claude-code"))
        #expect(TakeLabelFace.parts("english") == .init(yielding: nil, kept: "english"))
        #expect(TakeLabelFace.parts("") == .init(yielding: nil, kept: ""))
        // A separator with nothing before it, or nothing after it, splits nothing.
        #expect(TakeLabelFace.parts("\(dot)english") == .init(yielding: nil, kept: "\(dot)english"))
        #expect(TakeLabelFace.parts("claude-code\(dot)") == .init(yielding: nil, kept: "claude-code\(dot)"))
        #expect(TakeLabelFace.parts("claude-code\(dot)  ") == .init(yielding: nil, kept: "claude-code\(dot)  "))
        // A legacy label with no own words after the word.
        #expect(TakeLabelFace.parts("claude-code\(dot)suggested")
                == .init(yielding: "claude-code", kept: "\(dot)suggested"))
        // A plain middle dot without its spaces is not the separator.
        #expect(TakeLabelFace.parts("a\u{00B7}b") == .init(yielding: nil, kept: "a\u{00B7}b"))
        // The parts always rebuild the label exactly.
        for label in ["claude-code\(dot)english", "claude-code\(dot)suggested\(dot)english", "english", "x\(dot)y\(dot)z"] {
            let parts = TakeLabelFace.parts(label)
            #expect((parts.yielding ?? "") + parts.kept == label, "\(label)")
        }
    }

    // MARK: - The allocation (pure)

    @Test func theAllocationTable() {
        // Room for both, or no limit: each its ideal.
        #expect(TakeLabelFace.allocate(available: nil, yielding: 11, kept: 10) == (11, 10))
        #expect(TakeLabelFace.allocate(available: 21, yielding: 11, kept: 10) == (11, 10))
        #expect(TakeLabelFace.allocate(available: .infinity, yielding: 11, kept: 10) == (11, 10))
        // Short: the kept part whole first, the yielding part what is left.
        #expect(TakeLabelFace.allocate(available: 16, yielding: 11, kept: 10) == (6, 10))
        #expect(TakeLabelFace.allocate(available: 10, yielding: 11, kept: 10) == (0, 10))
        // Shorter than the kept part: all of it to the kept part.
        #expect(TakeLabelFace.allocate(available: 8, yielding: 11, kept: 10) == (0, 8))
        #expect(TakeLabelFace.allocate(available: 0, yielding: 11, kept: 10) == (0, 0))
        #expect(TakeLabelFace.allocate(available: -3, yielding: 11, kept: 10) == (0, 0))
        // A single part (no yielding part): today's one-run face.
        #expect(TakeLabelFace.allocate(available: 4, yielding: 0, kept: 7) == (0, 4))
        #expect(TakeLabelFace.allocate(available: 40, yielding: 0, kept: 7) == (0, 7))
    }
}
