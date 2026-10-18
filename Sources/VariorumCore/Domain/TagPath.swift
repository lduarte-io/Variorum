import Foundation

/// **A TYPED TAG PATH's SEGMENTS** (13n-a — hoisted into core from the app's
/// `Shared/TypedTagPath.segments`, which now delegates here).
///
/// The document format's `{#tag/path}` tokens are typed paths exactly like
/// the ones she types into a tag field, so the core import door must read
/// them by the same rule — and core cannot see the app target. One rule, one
/// home (the forked-brains rule): slash noise collapses forgivingly
/// ("/a//b/" is a/b), each segment trims its horizontal whitespace, empty
/// segments drop. A path that yields NO segment (`{#///}`) names no tag.
public enum TagPath {
    public static func segments(_ raw: String) -> [String] {
        // VX-357: any U+0000 is removed first (`StoredText.stripped` — the
        // store cannot hold one), so a path applied and a path looked up for
        // removal name the same tag, and a segment of nothing but null
        // characters is passed over like an empty one.
        StoredText.stripped(raw).split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
