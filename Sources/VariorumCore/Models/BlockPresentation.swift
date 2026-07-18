import Foundation

/// The block-level presentation frame (Phase 13, v1_9 — sitting rulings
/// R16/R27): the author's callout — "a separated little background color
/// block of text within the writing" (her Notion reference, sitting 3
/// image #7). Stored as canonical JSON in `block.presentation` (nullable
/// TEXT); identity-level like `block.name`; plain metadata under sync.
///
/// The shape is deliberately open strings, not enums: `kind` names the
/// frame family (today exactly "callout"), `color` names a THEME TOKEN
/// (the voice layer resolves it — storing a hex value would marry the
/// store to a palette, which the two-voices ruling R1 forbids), `emoji`
/// is the optional glyph (her example: "💡 goal <3"). Unknown kinds
/// decode and survive round trips — a future client's frame never
/// corrupts here (the SmartQuerySpec unknown-keys doctrine).
public struct BlockPresentation: Codable, Equatable, Sendable {
    /// The one shipping frame family.
    public static let calloutKind = "callout"

    public var kind: String
    /// A theme-token name (e.g. "blue", "sand") — resolved per voice at
    /// render time, never a literal color value.
    public var color: String?
    public var emoji: String?

    public init(kind: String = BlockPresentation.calloutKind,
                color: String? = nil, emoji: String? = nil) {
        self.kind = kind
        self.color = color
        self.emoji = emoji
    }

    /// The canonical encoding for `block.presentation` — sorted keys, so
    /// equal presentations are byte-equal (the no-op-write guard and CAS
    /// comparisons read bytes).
    public func encodedJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return String(decoding: try encoder.encode(self), as: UTF8.self)
    }

    /// Decodes a stored presentation. Malformed JSON reads as nil — a
    /// plain block, never a crash (fail-open on presentation: losing a
    /// frame renders prose; the fail-closed precedent is for QUERIES,
    /// where malformed must not over-match).
    public static func decode(_ json: String?) -> BlockPresentation? {
        guard let json else { return nil }
        return try? JSONDecoder().decode(BlockPresentation.self, from: Data(json.utf8))
    }
}

extension Block {
    /// The typed view of `presentation` (nil = a plain block; malformed
    /// stored JSON reads as plain too).
    public var blockPresentation: BlockPresentation? {
        BlockPresentation.decode(presentation)
    }
}
