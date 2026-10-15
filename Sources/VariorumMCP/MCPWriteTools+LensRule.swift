import Foundation
import GRDB
import MCP
import VariorumCore

/// **`save_lens` BY RULE — a label, or the takes the note shows now** (VX-253;
/// VX-336 U5a — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
/// whose U5a design argues every line below). Her ruling, *"I like your 253
/// recommendation"*, with her clarification built in:
///
/// - **three explicit fills, never a magic word** — the picks (`take_ids`),
///   `label`, or `pin_chosen: true`; the picks ride on either rule as per-block
///   overrides, applied FIRST, so a block a pick covers is never ambiguous;
/// - **a block with no take of that label** shows its chosen take (no pick: the
///   lens falls through, today's lens semantics) and is listed in
///   `unmatched_blocks`;
/// - **an AMBIGUOUS block** (two or more takes of that label) that no pick
///   covers refuses the WHOLE call, naming those blocks — and their matching
///   takes, so the retry (the same label plus `take_ids` for exactly those
///   blocks) needs no `read_note`;
/// - **labels match exactly as stored, plus the client's OWN suggestions by
///   their own part** — VX-267's `‹client› · ‹label›` and the legacy
///   `‹client› · suggested · ‹label›` — never another client's.
///
/// `pin_chosen` is her own **Save Choices as Lens…** on the wire: an EXPLICIT
/// pick, on every block, of the take the note shows there now (the store's one
/// render rule, `Queries.renderedVariantIDs` — the chosen take while live,
/// active and on its block, else the block's default — restricted to the ACTIVE
/// takes a lens may name), so her later ✓ never moves the lens.
///
/// The rule only RESOLVES picks: `Operations.saveLens` is untouched (one
/// transaction, its own validation of every pick, ONE client-named undo entry
/// whose halves already answer U2's question). Cost ∝ the note's blocks and
/// their takes — a rule speaks of every block — in two statements pinned on
/// the plan (`MCPLensRulePlanTests`).
extension MCPWriteTools {
    /// The rule a lens is filled by, beside (or instead of) the picks.
    enum LensRule: Sendable, Equatable {
        /// Each uncovered block: its ONE take with this label.
        case label(String)
        /// Each uncovered block: the take it shows now, pinned.
        case pinChosen
    }

    /// The word the takes a client added before VX-267 carry between its name
    /// and its label (`‹client› · suggested · ‹label›`) — read here only.
    static let legacySuggestionWord = "suggested"

    /// The most block ids one answer or refusal lists (the counts say the
    /// whole) — the house's per-answer bound (`MCPNoteStructure.carriageCap`).
    static let lensListCap = MCPNoteStructure.carriageCap

    /// No fill at all (the old schema REQUIRED `take_ids`; a rule may now stand alone).
    static let noLensFillWords = "Pass take_ids (the take to show per block), label, or pin_chosen: true."

    /// **Does a take's stored label answer the rule's `label` for `client`?**
    /// Exactly as stored, or the client's OWN suggestion by its own part — in
    /// VX-267's form or the legacy one. Byte-exact and case-sensitive; another
    /// client's suggestion answers only to its FULL stored label.
    static func labelAnswers(_ stored: String?, label: String, client: String) -> Bool {
        guard let stored else { return false }
        return stored == label
            || stored == client + labelSeparator + label
            || stored == client + labelSeparator + legacySuggestionWord + labelSeparator + label
    }

    // MARK: - Arguments (parsed BEFORE the executor — no decision has run, so no oracle)

    /// `label` / `pin_chosen` — at most one rule. `pin_chosen: false` is no rule.
    func parseLensRule(_ args: [String: Value]) throws -> LensRule? {
        var label: String?
        if let value = args["label"], value != .null {
            guard let string = value.stringValue else { throw ArgumentFailure(message: "label must be a string.") }
            guard !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ArgumentFailure(message: "label can't be blank.")
            }
            label = string
        }
        var pinChosen = false
        if let value = args["pin_chosen"], value != .null {
            guard case .bool(let flag) = value else {
                throw ArgumentFailure(message: "pin_chosen must be true or false.")
            }
            pinChosen = flag
        }
        switch (label, pinChosen) {
        case (.some, true):
            throw ArgumentFailure(message: "Pass label or pin_chosen, not both \u{2014} take_ids can ride either.")
        case (let label?, false): return .label(label)
        case (nil, true): return .pinChosen
        case (nil, false): return nil
        }
    }

    // MARK: - The rule's one read (∝ the note's blocks and their takes)

    /// The note's live placements in note order, with each block's chosen and
    /// default take ids — `idx_cblock_order (container_id=?)`, each block by key.
    static let lensRulePlacementsSQL = """
        SELECT cb.block_id, cb.chosen_variant_id, b.default_variant_id
        FROM container_block cb
        JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
        ORDER BY cb.position, cb.id
        """

    /// Those blocks' live ACTIVE takes (the only ones a lens may name), in fan
    /// order: the ids drive (`json_each`), each seeking its block's takes
    /// through `idx_variant_block (block_id=? AND status=?)` — **`CROSS JOIN` on
    /// purpose** (the house's `json_each` discipline: `picksSQL`,
    /// `placedBlocksSQL`). One placeholder: the block ids as a JSON array.
    static let lensRuleTakesSQL = """
        SELECT v.id, v.block_id, v.label FROM json_each(?) j
        CROSS JOIN variant v ON v.block_id = j.value AND v.status = 'active' AND v.deleted_at IS NULL
        ORDER BY v.fan_position, v.id
        """

    /// What a rule filled: a pick per block it resolved, and the blocks it
    /// left to their chosen take (note order).
    struct LensFill: Sendable, Equatable {
        var picks: [String: String] = [:]
        var unmatched: [String] = []
    }

    /// One uncovered block a label matched more than once, with its matching
    /// takes in fan order.
    struct AmbiguousBlock: Sendable, Equatable {
        let blockID: String
        let takes: [(id: String, label: String)]

        static func == (lhs: AmbiguousBlock, rhs: AmbiguousBlock) -> Bool {
            lhs.blockID == rhs.blockID && lhs.takes.map(\.id) == rhs.takes.map(\.id)
                && lhs.takes.map(\.label) == rhs.takes.map(\.label)
        }
    }

    /// **The rule, resolved over the note** — every block `covered` by a pick
    /// is skipped (the picks come first). Called inside the act's closure,
    /// after the decision allowed the note.
    func fillLens(
        _ rule: LensRule, noteID: String, clientName: String, covered: Set<String>
    ) throws -> LensFill {
        let (placements, takes) = try database.read { db -> ([Row], [String: [Row]]) in
            let placements = try Row.fetchAll(db, sql: Self.lensRulePlacementsSQL, arguments: [noteID])
            let json = String(decoding: try JSONEncoder().encode(placements.map { $0["block_id"] as String }),
                              as: UTF8.self)
            var takes: [String: [Row]] = [:]
            for row in try Row.fetchAll(db, sql: Self.lensRuleTakesSQL, arguments: [json]) {
                takes[row["block_id"], default: []].append(row)
            }
            return (placements, takes)
        }
        var fill = LensFill()
        switch rule {
        case .label(let label):
            var anyMatch = false
            var ambiguous: [AmbiguousBlock] = []
            for placement in placements {
                let blockID: String = placement["block_id"]
                let matching = (takes[blockID] ?? []).filter {
                    Self.labelAnswers($0["label"], label: label, client: clientName)
                }
                if !matching.isEmpty { anyMatch = true }
                guard !covered.contains(blockID) else { continue }
                switch matching.count {
                case 0: fill.unmatched.append(blockID)
                case 1: fill.picks[blockID] = matching[0]["id"]
                default:
                    ambiguous.append(AmbiguousBlock(
                        blockID: blockID, takes: matching.map { ($0["id"] as String, $0["label"] as String? ?? "") }))
                }
            }
            // PROVISIONAL P-VX253-2: a label no take of the note wears names
            // nothing — such a lens would read exactly as the note (a mistyped
            // label would leave her a junk lens a suggest client can't delete).
            guard anyMatch else {
                throw ArgumentFailure(message: "No take in this note is labelled \u{201C}\(label)\u{201D} \u{2014} nothing was saved.")
            }
            guard ambiguous.isEmpty else {
                throw ArgumentFailure(message: Self.ambiguityWords(label: label, ambiguous))
            }
        case .pinChosen:
            for placement in placements {
                let blockID: String = placement["block_id"]
                guard !covered.contains(blockID) else { continue }
                let active = Set((takes[blockID] ?? []).map { $0["id"] as String })
                let candidates: [String?] = [placement["chosen_variant_id"], placement["default_variant_id"]]
                if let shown = candidates.compactMap({ $0 }).first(where: { active.contains($0) }) {
                    fill.picks[blockID] = shown
                } else {
                    // A block whose shown take is no ACTIVE take (an archived
                    // default — a render edge): no pick, it still shows it.
                    fill.unmatched.append(blockID)
                }
            }
        }
        return fill
    }

    /// The ambiguity refusal: a sentence, then ONE line of JSON naming the
    /// blocks (the first `lensListCap`, note order) and each one's matching
    /// takes (fan order, stored labels) — every id one the client can already
    /// read (a block of the note it was allowed, an active take of it).
    static func ambiguityWords(label: String, _ blocks: [AmbiguousBlock]) -> String {
        let noun = blocks.count == 1 ? "one block" : "\(blocks.count) blocks"
        let sentence = "label \"\(label)\" matches more than one take on \(noun), and a lens shows one take per block. "
            + "Call again with the same label and take_ids naming the take to show on each of these blocks:"
        let listed: [[String: Any]] = blocks.prefix(lensListCap).map { block in
            ["block_id": block.blockID, "takes": block.takes.map { ["take_id": $0.id, "label": $0.label] }]
        }
        let tail: [String: Any] = ["ambiguous_blocks": listed, "ambiguous_count": blocks.count]
        guard let data = try? JSONSerialization.data(withJSONObject: tail, options: [.sortedKeys, .withoutEscapingSlashes])
        else { return sentence }
        return sentence + "\n" + String(decoding: data, as: UTF8.self)
    }
}
